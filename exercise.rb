require 'yaml'
require 'json'
require 'faraday'

class Exercise
  config = YAML.load_file("config.yml")
  DOMAIN = config['github']['domain'].freeze
  SCORES = Hash.new(1)
  SCORES.merge!(config['github']['scores']).freeze

  # initialize profile and client
  def initialize(user='DHH')
    @user_profile = user
    @client = Faraday.new(url: DOMAIN)
  end

  # get github response,
  # calculate and display score,
  # handle error
  def get_score
    response = get_response(get_url)
    return puts "Failed for profile #{@user_profile}" if (response[:status] != 200)
    begin
      total_score = calculate_score(response[:body])
      message = "#{@user_profile}'s github score is #{total_score}"
    rescue Exception => e
      message = "Could not complete the request due to Error: #{e.inspect}"
    end
    return puts message
  end

  private
  # get response
  # parse json response
  def get_response(url)
    response =  @client.get do |request|
                    request.url url
                end
    return {status: response.status, body: JSON.parse(response.body)}
  end

  # get profile url
  def get_url
    return (DOMAIN + "/users/#{@user_profile}/events/public")
  end

  # calculate score from response
  def calculate_score(body)
    body.reduce(0) {|score, record| score + SCORES[record['type']]}
  end
end

Exercise.new.get_score
