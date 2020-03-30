class Stripe
  def create_invoice(
    customer : String | Customer? = nil,
    auto_advance : Bool? = nil,
    default_source : String | Token? = nil,
    default_payment_method : String | Token? = nil,
    metadata : Hash? = nil,
    subscription : String? = nil,
    statement_descriptor : String? = nil
  ) : Invoice forall T, U
    case default_source
    when Token
      default_source = default_source.id
    end

    case default_payment_method
    when Token, PaymentMethods::Card
      default_payment_method = default_payment_method.not_nil!.id
    end

    validate items, {{U}} do
      type id : String,
        type quantity : Int32,
          type plan : String
    end

    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(customer auto_advance default_source metadata default_payment_method subscription) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = @client.post("/v1/invoice", form: io.to_s)

    if response.status_code == 200
      return Invoice.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
