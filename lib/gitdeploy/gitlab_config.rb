require 'ostruct'

module Gitdeploy
  class GitlabConfig < OpenStruct
    def sign_in_url
      "https://#{host}/users/sign_in"
    end

    def network_url
      "https://#{host}/#{Gitdeploy.customer}/#{Gitdeploy.project}/network/develop.json"
    end
  end
end
