require 'faraday_middleware'

class Exercise
  DOMAIN = 'https://api.github.com/'.freeze

  def initialize(user='DHH')
    @type_scores = get_type_wise_scores.freeze
    @client = get_response
    @user_profile = user
  end

  def get_score
    response = @client.get(url)
    return "Failed for profile #{@user_profile}, " unless response.success?
    begin
      total_score = response.body.reduce(0) {|score, record| score + @type_scores[record['type']]}
      message = "#{@user_profile}'s github score is #{total_score}"
    rescue Exception => e
      message = "Could not complete the request due to Error: #{e.inspect}"
    end
    puts message
  end

  private
  def get_type_wise_scores
    scores = Hash.new(1)
    scores['IssuesEvent'] = 7
    scores['IssueCommentEvent'] = 6
    scores['PushEvent'] = 5
    scores['PullRequestReviewCommentEvent'] = 4
    scores['WatchEvent'] = 3
    scores['CreateEvent'] = 2
    return scores
  end

  def get_response
    connection =  Faraday.new do |f|
                    f.response :json
                    f.adapter :net_http
                  end
    return connection
  end

  def url
    return (DOMAIN + "users/#{@user_profile}/events/public")
  end
end

Exercise.new.get_score
