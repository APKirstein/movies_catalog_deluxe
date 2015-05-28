require 'sinatra'
require 'pg'
require 'cgi'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end


get '/' do
  redirect '/actors'
end

get '/actors' do
  actors_data = db_connection { |conn| conn.exec("SELECT name FROM actors ORDER BY name;") }
  actors_data = actors_data.to_a

  erb :'actors/index', locals: { actors: actors_data}
end

get '/actors/:id' do
  actor_info = db_connection { |conn| conn.exec("SELECT movies.title, cast_members.characters FROM actors
    LEFT JOIN cast_members ON (cast_members.actor_id = actors.id)
    LEFT JOIN movies ON (movies.actor_id = actors.id)
    WHERE actors.name = '#{params['id']}';") }
  actor_info = actor_info.to_a

  erb :'actors/show', locals: { actor_info: actor_info, actor_name: params['id'] }
end

get '/movies' do
  movies_data = db_connection { |conn| conn.exec("SELECT movies.title, movies.year, movies.rating, genres.name, studios.name FROM movies
     LEFT JOIN genres ON (genres.id = movies.genre_id)
     LEFT JOIN studios ON (studios.id = movies.studio_id)
     ORDER BY genres.name;") }
  movies_data = movies_data.to_a
# binding.pry
  erb :'movies/index', locals: { movies: movies_data}
end

get '/movies/:id' do
  movie_info = db_connection { |conn| conn.exec("SELECT genres.name AS genre, studios.name AS studio, actors.name, cast_members.character FROM movies
    LEFT JOIN cast_members ON movies.id = cast_members.movie_id
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id
    LEFT JOIN actors ON cast_members.actor_id = actors.id
    WHERE movies.title = '#{params['id']}';") }
    movie_info = movie_info.to_a

  erb :'movies/show', locals: {movie_title: params["id"], movie_info: movie_info}
end
