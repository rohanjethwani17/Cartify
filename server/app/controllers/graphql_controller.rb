class GraphqlController < ApplicationController
  # Skip CSRF for API endpoint
  skip_before_action :verify_authenticity_token, raise: false

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user,
      current_store: nil,
      request: request
    }

    result = CartifySchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    handle_error(e)
  end

  private

  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: {
      errors: [{ message: e.message, backtrace: Rails.env.development? ? e.backtrace : nil }],
      data: {}
    }, status: :internal_server_error
  end
end
