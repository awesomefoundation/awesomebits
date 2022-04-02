class VoteMigrator
  def migrate!(explicit_mappings: {})
    migrate_voter_in_chapter!
    migrate_any_chapter_votes!
    migrate_non_any_chapter_votes!
    migrate_production!(explicit_mappings: explicit_mappings)
  end

  def migrate_voter_in_chapter!
    # Assign all votes for projects where the voter is in the chapter
    votes = Vote
              .where(chapter_id: nil)
              .select(:id, Project.arel_table[:chapter_id])
              .joins({ user: :roles }, :project)
              .where(Role.arel_table[:chapter_id].eq(Project.arel_table[:chapter_id]))

    update_votes(votes)
  end

  def migrate_any_chapter_votes!
    # Assign all votes for projects in the Any chapter
    votes = Vote.where(chapter_id: nil).joins(project: :chapter).merge(Project.where(chapter: Chapter.any_chapter))
    votes_by_user = votes.each_with_object({}) { |v, memo| memo[v.user_id] ||= []; memo[v.user_id] << v }

    ## For each vote, get all of the other votes for that user
    ## If they're all the same, assign this vote to that chapter
    votes_by_user.each do |user_id, user_votes|
      user = User.find(user_id)

      other_votes_chapters = user.votes.joins(project: :chapter).merge(Project.where.not(chapter: Chapter.any_chapter)).pluck(Project.arel_table[:chapter_id]).uniq
      if other_votes_chapters.size == 1
        puts "Updating User##{user_id} 'Any' chapter votes to Chapter##{other_votes_chapters.first} (#{user_votes.size} votes)"
        Vote.where(id: user_votes.map(&:id)).update_all(chapter_id: other_votes_chapters.first)
      elsif other_votes_chapters.empty? && user.chapters.size == 1
        puts "User##{user_id} has no other votes and is in one chapter, assigning votes to Chapter##{user.chapters.first.id} (#{user_votes.size} votes)"
        Vote.where(id: user_votes.map(&:id)).update_all(chapter_id: user.chapters.first.id)
      else
        puts "User##{user_id} had votes in chapters #{other_votes_chapters.inspect}, skipping."
      end
    end
  end

  def migrate_non_any_chapter_votes!
    ## Get the votes that have not been assigned yet that are not part of the Any chapter
    votes = Vote.where(chapter_id: nil).joins(project: :chapter).includes(project: :chapter).merge(Project.where.not(chapter: Chapter.any_chapter))
    votes_by_user = votes.includes(:user).each_with_object({}) { |v, memo| memo[v.user] ||= []; memo[v.user] << v }

    votes_by_user.each do |user, user_votes|
      chapter_ids = user_votes.collect { |vote| vote.project.chapter_id }.uniq
      if chapter_ids.size == 1
        puts "User##{user.id} only has votes for Chapter##{chapter_ids.first}, assigning votes to that chapter (#{user_votes.size} votes)"
        Vote.where(id: user_votes.map(&:id)).update_all(chapter_id: chapter_ids.first)
      end
    end
  end

  def migrate_production!(explicit_mappings: {})
    # These user's votes should be associated with the user's main chapter
    user_maps = explicit_mappings["user_to_chapter_maps"].to_a

    user_maps.each do |user_id, chapter_id|
      puts "Explicitly updating User##{user_id} vote chapters to Chapter##{chapter_id}"
      Vote.where(chapter_id: nil, user_id: user_id).joins(:project).update_all(chapter_id: chapter_id)
    end

    # These Votes just need to be updated explicitly
    explicit_mappings["vote_to_chapter_maps"].to_a.each do |vote_id, chapter_id|
      puts "Explicitly updating Vote##{vote_id} to Chapter##{chapter_id}"
      Vote.find(vote_id).update(chapter_id: chapter_id)
    end

    # These user's votes should be associated with the project's chapter
    user_ids = explicit_mappings["project_chapter_user_ids"].to_a
    any_chapter = Chapter.any_chapter

    # Iterate over every vote and set the chapter_id to the project's chapter
    # For the Any chapter, set the chapter to the previously seen real chapter
    user_ids.each do |user_id|
      puts "Explicitly updating User##{user_id} vote chapters to that project's chapter"
      previous_chapter = nil
      User.find(user_id).votes.joins(:project).includes(:project).order(:created_at).each do |vote|
        if vote.project.chapter_id == any_chapter.id
          vote.update(chapter_id: previous_chapter&.id) if vote.chapter_id.nil?
        else
          vote.update(chapter_id: vote.project.chapter.id) if vote.chapter_id.nil?
          previous_chapter = vote.project.chapter
        end
      end
    end
  end

  private

  def update_votes(scope)
    sql = <<-SQL
      UPDATE votes SET chapter_id=votes_to_update.chapter_id
      FROM (#{scope.to_sql}) AS votes_to_update
      WHERE votes_to_update.id=votes.id
    SQL

    puts
    puts sql

    updated = ActiveRecord::Base.connection.update(Arel.sql(sql))

    puts "#{updated} updated"
    puts
  end
end
