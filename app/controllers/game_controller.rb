class GameController < ApplicationController

  before_action :get_game_from_session
  after_action  :store_game_in_session
  
  private
  
  def get_game_from_session
    @game = HangpersonGame.new('')
    @db = Database.new()
    if !session[:game].blank?
      @game = YAML.load(session[:game])
    end
    if !session[:db].blank?
      @db = YAML.load(session[:db])
    end
  end

  def store_game_in_session
    session[:game] = @game.to_yaml
    session[:db] = @db.to_yaml
  end

  public
  
  def new
  end

  def create
    word = params[:word] || HangpersonGame.get_random_word
    @game = HangpersonGame.new(word)
    redirect_to game_path
  end

  def show
    status = @game.check_win_or_lose
    redirect_to win_game_path if status == :win
    redirect_to lose_game_path if status == :lose
  end

  def guess
    letter = params[:guess]
    begin
      if ! @game.guess(letter[0])
        flash[:message] = "You have already used that letter." 
      end
    rescue ArgumentError
      flash[:message] = "Invalid guess."
    end
    redirect_to game_path
  end

  def win
    redirect_to game_path unless @game.check_win_or_lose == :win
  end
  
  def lose
    redirect_to game_path unless @game.check_win_or_lose == :lose
  end

  def my_measurements
    
    puts("Displaying my measurements page")
  end
  
  def enter_my_measurements
    puts("Displaying enter my measurements page")
  end
  
  def process_enter_new_measurements
    weight = params[:weight]
    body_fat = params[:body_fat]
    height = params[:height]
    @db.process_enter_new_measurements(weight, body_fat, height)
    
    redirect_to my_measurements_path
  end 
end