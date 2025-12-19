# CORS configuration for API access

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # In production, restrict to your frontend domain

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: ['Authorization'],
             max_age: 600
  end
end
