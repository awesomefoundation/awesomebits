json.data do
  json.array! @chapters do |chapter|
    json.name chapter.display_name
    json.purpose t('home.index.title')
    json.location chapter.country
    json.chapter_url chapter_url(chapter.slug)
    json.website chapter.blog_url.presence
    json.description chapter.description.presence
    json.number_of_members chapter.users.size
    json.number_of_projects chapter.winning_projects.size
    json.total_amount_granted_in_dollars chapter.winning_projects.size * chapter.grant_amount_dollars
    json.twitter_url chapter.twitter_url.presence
    json.facebook_url chapter.facebook_url.presence
    json.instagram_url chapter.instagram_url.presence
    json.active chapter.active?
    json.email chapter.email_address.presence
    json.is_virtual chapter.global?
    json.is_accepting_members true
    json.contact_title t('users.index.dean')
    json.typical_grant_amount_in_dollars chapter.grant_amount_dollars
    json.typical_grant_frequency chapter.grant_frequency
    json.image_profile_url image_url('logo-800x800.png')
    json.image_banner_url image_url('logo-banner-1680x626.png')

    if params[:include_projects].present?
      json.projects chapter.winning_projects do |project|
        json.recipient project.title
        json.date project.funded_on
      end
    end
  end
end
