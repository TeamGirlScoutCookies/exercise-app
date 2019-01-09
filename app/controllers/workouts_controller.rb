class WorkoutsController < ApplicationController

  before_action :get_db_from_session
  after_action  :store_db_in_session
  
  private
  
  def get_db_from_session

    @db = Database.new()
    
    if !session[:db].blank?
      @db = YAML.load(session[:db])
    end
  end

  def store_db_in_session

    session[:db] = @db.to_yaml
  end
  
  public
  
  def new
  end
  
  def my_workouts
    puts("Displaying my workouts page")
    puts("User has uid: #{session[:user_id]}")
    @workouts = Workout.where(uid: session[:user_id])
    @workouts = [] if (@workouts.nil?)
  end

  def homepage
    puts("Go back to the homepage")
  end
  
  def process_create_workout
    puts("Inserting new workout to database...")
    name = params[:name]
    
    Workout.create(uid: session[:user_id], name: name)
  
    redirect_to my_workouts_path
  end
  
end
