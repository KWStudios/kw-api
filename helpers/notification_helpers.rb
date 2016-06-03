# encoding: utf-8

# Helpers for the Notification system
module NotificationHelpers
  # rubocop:disable MethodLength, AbcSize
  def send_notification_to_profile(title, body, profile)
    return if profile.nil?

    installations = get_installations_for_profile(profile)

    registration_ids = []
    installations.each do |installation|
      registration_ids << installation.gcm_token
    end

    json_notification_hash = { sound: 'default', title: title, body: body,
                               badge: '1' }
    json_body_hash = { registration_ids: registration_ids,
                       notification: json_notification_hash,
                       priority: 'normal' }

    request = Typhoeus::Request.new(
      'https://fcm.googleapis.com/fcm/send',
      method: :post,
      body: JSON.generate(json_body_hash),
      headers: { 'Content-Type' => 'application/json',
                 Authorization: "key=#{ENV['GCM_API_KEY']}" }
    )
    request.run

    response = request.response.body
    puts response
  end
end
