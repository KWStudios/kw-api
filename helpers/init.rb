# encoding: utf-8
require_relative 'partials'
KWApi.helpers LoginHelpers
KWApi.helpers ErrorCreators

require_relative 'geocoding'
KWApi.helpers GeocodingHelpers

require_relative 'dog_helpers'
KWApi.helpers DogHelpers

require_relative 'installation_helpers'
KWApi.helpers InstallationHelpers

require_relative 'notification_helpers'
KWApi.helpers NotificationHelpers

require_relative 'fb_login_helpers'
KWApi.helpers FBLoginHelpers
