class PagesController < ApplicationController


    require 'open-uri'
    require 'json'

  def game


    @grid = Array.new(9) { ('A'..'Z').to_a.sample }
  end



  def score
    @grid = params[:grid].scan /\w/
    @end_time = DateTime.now
    @attempt = params[:attempt]

    @time_taken = @end_time.to_i - (params[:start_time]).to_datetime.to_i

    @result = { time: @time_taken }
    @score_and_message = score_and_message(@attempt, @grid, @result[:time])
    @result[:score] = @score_and_message.first
    @result[:message] = @score_and_message.last
    return @result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
