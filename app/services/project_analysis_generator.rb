require "openai"
require "nokogiri"

class ProjectAnalysisGenerator
  def initialize(project_id)
    @project = Project.find(project_id)
    openai_config = Rails.application.config_for(:openai)

    # puts(JSON.generate({openai_config: openai_config}, indent: "  "))

    @openai_api_key = openai_config[:api_key]
    raise "Error: OPENAI_API_KEY is not set in the configuration." if @openai_api_key.blank?

    @client = OpenAI::Client.new(
      access_token: @openai_api_key,
      log_error: true
    )

    config = openai_config[:project_analysis]
    @model = config[:model]
    @prompt = config[:prompt_text]
    @format_instructions = config[:format_instructions]
    @response_schema = config[:response_schema]
  end

  def call
    project_data = prepare_project_data
    response = make_api_call(project_data)

    if response.nil?
      raise "Error: OpenAI API call failed."
    end

    parse_and_save_response(response)
  end

  private

  def prepare_project_data
    {
      "project_id" => @project.id,
      "title" => @project.title,
      "about_me" => @project.about_me,
      "about_project" => @project.about_project,
      "use_for_money" => @project.use_for_money,
      "created_at" => @project.created_at,
      "chapter_name" => @project.chapter.name,
      "chapter_country" => @project.chapter.country,
      "chapter_description" => Nokogiri::HTML.fragment(@project.chapter.description).text.strip,
      "extra_questions" => [
        {question: @project.extra_question_1, answer: @project.extra_answer_1},
        {question: @project.extra_question_2, answer: @project.extra_answer_2},
        {question: @project.extra_question_3, answer: @project.extra_answer_3}
      ].reject { |qa| qa[:question].blank? && qa[:answer].blank? }
    }
  end

  def make_api_call(project_data)
    parameters = {
      model: @model,
      messages: [
        {role: "user", content: @prompt},
        {role: "user", content: project_data.to_json},
        {role: "user", content: @format_instructions}
      ],
      functions: [
        {
          name: "structured_output",
          parameters: @response_schema
        }
      ],
      function_call: "auto"
    }
    response = @client.chat(parameters: parameters)
    # Avoid noisy output in tests/production. Use logger if needed.
    # puts(JSON.generate({response: response}, indent: "  "))
    # response.merge(
    #   "prompt_usage_data" => { "total_tokens" => 800, "prompt_tokens" => 500, "completion_tokens" => 300 },
    #   "prompt_estimated_cost" => 0.02
    # )
    response
  rescue => e
    Rails.logger.error("OpenAI API call failed: #{e}")
    nil
  end

  def parse_and_save_response(response)
    response_messages = response.dig("choices", 0, "message")
    response_data = if response_messages["function_call"]
      JSON.parse(response_messages["function_call"]["arguments"])
    else
      JSON.parse(response_messages["content"])
    end

    project_analysis_attributes = map_response_to_attributes(response_data)

    project_analysis = ProjectAnalysis.find_or_initialize_by(project_id: @project.id)
    project_analysis.assign_attributes(project_analysis_attributes)
    project_analysis.save!

    project_analysis
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse OpenAI response: #{e.message}")
    nil
  end

  def map_response_to_attributes(response_data)
    project_analysis_attributes = {
      summary: response_data["summary"],
      language_code: response_data["language_code"],
      applicant_role: response_data["applicant_role"],
      funding_deadline: response_data["funding_deadline"],
      tags: response_data["tags"],
      suggestion: response_data["suggestions"]
      # prompt_usage_data: response["usage"]
    }

    # Parse scores
    scores = response_data["scores"]

    ProjectAnalysisScores::SCORE_FIELDS.each do |field|
      score_data = scores[field]

      if score_data
        project_analysis_attributes["#{field}_score"] = score_data["score"]
        project_analysis_attributes["#{field}_score_reason"] = score_data["reason"]
      else
        Rails.logger.warn("Score for #{field} is missing in the response.")
      end
    end

    project_analysis_attributes
  end
end
