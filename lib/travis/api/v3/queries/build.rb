module Travis::API::V3
  class Queries::Build < Query
    params :id

    def find
      return ::Build.find_by_id(id) if id
      raise WrongParams
    end
  end
end
