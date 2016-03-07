# encoding: utf-8

# Helpers for all app installation related stuff
module InstallationHelpers
  def get_installation_json_string(installation)
    gcm_json_hash = get_installation_json_hash(installation)
    gcm_json_string = JSON.generate(gcm_json_hash)
    gcm_json_string
  end

  def get_installation_json_hash(installation)
    gcm_json_hash = { gcm_token: installation.gcm_token,
                      device_identifier: installation.device_identifier,
                      created_at: installation.created_at,
                      updated_at: installation.updated_at }
    gcm_json_hash
  end

  def get_installations_for_profile(profile)
    installations = profile.installations.all
    installations
  end
end
