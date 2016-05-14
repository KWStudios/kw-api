# encoding: utf-8

# Helpers for the Braintree stuff
module BraintreeHelpers
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_payment_method_json_hash(payment_method)
    return {} if payment_method.nil? || !payment_method.is_a?(PaymentMethod)

    result = Braintree::PaymentMethod.find(payment_method.token)
    return {} if result.nil?

    default = result.default?

    last_4 = nil
    card_type = nil
    debit = nil
    expiration_month = nil
    expiration_year = nil
    expired = nil
    email = nil
    type_string = nil

    type = result.class
    puts "Type: #{type.inspect}"
    if type.is_a? Braintree::CreditCard
      last_4 = type.last_4
      card_type = type.card_type
      debit = type.debit
      expiration_month = type.expiration_month
      expiration_year = type.expiration_year
      expired = type.expired?
      type_string = 'creditcard'
    elsif type.instance_of? Braintree::PayPalAccount
      email = type.email
      type_string = 'paypal'
    end

    payment_json_hash = { id: payment_method.id,
                          default: default, last_4: last_4,
                          card_type: card_type, debit: debit,
                          expiration_month: expiration_month,
                          expiration_year: expiration_year,
                          expired: expired, email: email,
                          type: type_string }
    payment_json_hash
  end

  def get_payment_method_json_string(payment_method)
    payment_json_hash = get_payment_method_json_hash(payment_method)
    payment_json_string = JSON.generate(payment_json_hash)
    payment_json_string
  end
end
