class Rack::Attack
  cache.store = ActiveSupport::Cache::MemoryStore.new

  class Request < ::Rack::Request
    def subdomain
      url.split('/')
    end
  end
end
