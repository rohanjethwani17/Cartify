module Mutations
  class SignIn < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :user, Types::UserType, null: true
    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.downcase)

      if user&.authenticate(password)
        {
          user: user,
          token: user.generate_jwt,
          errors: []
        }
      else
        {
          user: nil,
          token: nil,
          errors: ['Invalid email or password']
        }
      end
    end
  end
end
