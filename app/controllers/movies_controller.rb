class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G','PG','PG-13','R']  #Movie.get_ratings <- doesn't work for some reason
    if params[:ratings]
      @movies = Movie.where(rating: params[:ratings].keys)
      #@all_ratings.each { |rating| session[:checked_ratings][rating] = false }
      session.delete(:checked_ratings)
      params[:ratings].each { |rating| session[:checked_ratings][rating.key] = true }
    elsif session[:checked_ratings]
      #flash.keep
      #redirect_to movies_path(ratings: session[:checked_ratings]) <- couldn't get redirect to work
      @movies = Movie.where(rating: session[:checked_ratings].keys)
    else
      session[:checked_ratings] = Hash.new
      @all_ratings.each { |rating| session[:checked_ratings][rating] = true }
      @movies = Movie.all
    end
    @checked_ratings = session[:checked_ratings] # <- THIS IS NOT NIL. THIS SHOULD NEVER BE NIL. WHY DOES IT SAY IT'S NIL. WHY THE F*
    if params[:sort] == "title"
      session[:sorting] = "title"
      @movies = @movies.order(:title)
      @title_header = 'hilite'
    elsif params[:sort] == "release_date"
      session[:sorting] = "release_date"
      @movies = @movies.sort { |a, b| a.release_date.to_i <=> b.release_date.to_i }
      @release_date_header = 'hilite'
    elsif session[:sorting] == "title"
      @movies = @movies.order(:title)
      @title_header = 'hilite'
    elsif session[:sorting] == "release_date"
      @movies = @movies.sort { |a, b| a.release_date.to_i <=> b.release_date.to_i }
      @release_date_header = 'hilite'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end