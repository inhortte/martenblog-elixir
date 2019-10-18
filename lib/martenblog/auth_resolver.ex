defmodule Martenblog.AuthResolver do
  require Logger

  def new_token do
    token = UUID.uuid4
    Mongo.insert_one(:mongo, "token", %{ token: token, created_at: DateTime.utc_now |> DateTime.to_unix })
    token
  end

  def expire_token(token) do
    if !is_nil(token) do
      Mongo.delete_one(:mongo, "token", %{ token: token })
      token
    end
  end

  def verify_token(token) do
    !is_nil(Mongo.find_one(:mongo, "token", %{ token: token }))
  end

  def verify_password(pass) do
    String.equivalent?(pass, "M7st#l1dnugis")
  end
end
