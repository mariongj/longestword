require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    grid_size = 9
    grid = []
    (0...grid_size).each do |i|
      grid[i] = ('A'..'Z').to_a.sample
    end
    @grid = grid
    @start_time = Time.now
  end

  def score
    #(attempt, grid, start_time, end_time)
    @attempt = params[:attempt]
    @grid = params[:grid].split(' ')
    @time = end_time - Time.parse(params[:start_time])
    @translation = translation(@attempt)
    @score = compute_score(@time, @attempt, @grid)
    @message = message(@attempt, @grid)
    session[:number_of_games] ||= 0
    session[:number_of_games] += 1
    @number_of_games = session[:number_of_games]
  end

  private

  def end_time
    Time.now
  end

  def translation(attempt)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    open(api_url) do |stream|
      word_reference_info = JSON.parse(stream.read)
      if word_reference_info['term0'].nil?
        translation = nil
      else
        translation = word_reference_info['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
      end
      translation
    end
  end

  def compute_score(time, attempt, grid)
    score = 0
    if translation(attempt) && (attempt.upcase.chars - grid).empty? && attempt.upcase.chars.all? { |letter| attempt.upcase.chars.count(letter) <= grid.count(letter) }
      score = attempt.size - @time.to_i
    end
    score
  end

  def message(attempt, grid)
    if translation(attempt).nil?
      "not an english word"
    else
      if (attempt.upcase.chars - grid).empty? && attempt.upcase.chars.all? { |letter| attempt.upcase.chars.count(letter) <= grid.count(letter) }
        "well done"
      else
        "not in the grid"
      end
    end
  end
end
