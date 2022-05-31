module SpamChecker
  class Project
    attr_accessor :project

    def initialize(project)
      @project = project
    end

    def call
      if spam?
        project.errors.add(:base, :spam_detected)
        true
      end
    end

    def spam?
      if fields_to_check.all? { |field| field.present? } && fields_to_check.uniq.size == 1
        true
      elsif [project.about_me, project.about_project, project.use_for_money].any? { |field| field&.match?(blocklist) }
        true
      else
        false
      end
    end

    private

    def fields_to_check
      [project.about_me, project.about_project, project.use_for_money]
    end

    def blocklist
      ["--test-spam-string--", ENV['SPAM_REGEXP']].reject(&:blank?).join("|")
    end
  end
end
