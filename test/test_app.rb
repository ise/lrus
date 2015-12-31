ENV['RACK_ENV'] ||= 'test'
ENV['MONGOLAB_URI'] = 'mongodb://localhost:27017/lrus-test'
require 'minitest/autorun'
require_relative '../app'

describe App do
  include Rack::Test::Methods

  after do
    MONGO.collections.each(&:drop)
  end

  def app
    App
  end

  describe 'POST /:name/:branch' do
    it 'string' do
      post '/foo/bar'
      assert last_response.body == 'foo1'
    end

    it 'same' do
      post '/foo/bar'
      post '/foo/bar'
      assert last_response.body == 'foo1'
    end

    it 'other' do
      post '/foo/bar'
      post '/foo/baz'
      assert last_response.body == 'foo2'
    end

    it 'same2' do
      post '/foo/bar'
      post '/foo/baz'
      post '/foo/bar'
      assert last_response.body == 'foo1'
    end

    it 'evict' do
      post '/foo/foo' # => foo1
      post '/foo/bar' # => foo2
      post '/foo/baz' # => foo3
      post '/foo/qux' # => foo1
      assert last_response.body == 'foo1'
      post '/foo/foo' # => foo2
      assert last_response.body == 'foo2'
    end

    it 'template' do
      post '/foo/bar', tmpl: ''
      assert last_response.body == ''

      post '/foo/bar', tmpl: 'FOO'
      assert last_response.body == 'FOO'

      post '/foo/bar', tmpl: '${name}-${n}-${b}'
      assert last_response.body == 'foo-1-bar'
    end
  end
end