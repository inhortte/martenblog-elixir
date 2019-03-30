defmodule Martenblog.Schema do
  use Absinthe.Schema
  require Logger

  alias Martenblog.BlogResolver
  alias Martenblog.PoemResolver

  object :topic do
    field :_id, :id
    field :topic, :string
    field :entry_ids, list_of(:id)
    field :count, :integer
  end

  object :entry do
    field :_id, :id
    field :entry, :string
    field :created_at, :integer
    field :subject, :string
    field :topic_ids, list_of(:id)
    field :topics, list_of(:topic)
  end

  object :poem do
    field :_id, :id
    field :filename, non_null(:string)
    field :title, non_null(:string)
    field :fecha, non_null(:string)
    field :normalised_title, non_null(:string)
    field :poem, non_null(:string)
  end

  query do
    # blog
    field :all_topics, list_of(non_null(:topic)) do
      resolve &BlogResolver.all_topics/3
    end
    field :last_topic, non_null(:topic) do
      resolve &BlogResolver.last_topic/3
    end
    field :p_count, non_null(:integer) do
      arg :topic_ids, list_of(non_null(:id))
      arg :search, :string
      resolve &BlogResolver.p_count/3
    end
    field :entries_paged, list_of(non_null(:entry)) do
      arg :page, non_null(:integer)
      arg :limit, :integer
      arg :topic_ids, list_of(non_null(:id))
      arg :search, :string
      resolve &BlogResolver.entries_paged/3
    end
    field :entry_by_id, non_null(:entry) do
      arg :id, non_null(:id)
      resolve &BlogResolver.entry_by_id/3
    end
    field :entries_by_date, list_of(non_null(:entry)) do
      arg :y, non_null(:integer)
      arg :m, non_null(:integer)
      arg :d, non_null(:integer)
      resolve &BlogResolver.entries_by_date/3
    end
    field :alrededores, list_of(:integer) do
      arg :timestamp, non_null(:integer)
      resolve &BlogResolver.alrededores/3
    end
    field :topics_by_ids, list_of(non_null(:topic)) do
      arg :ids, non_null(list_of(non_null(:id)))
      resolve &BlogResolver.topics_by_ids/3
    end

    # poems
    field :all_poems, list_of(:poem) do
      resolve &PoemResolver.all_poems/3
    end
  end

  def middleware(middleware, %{identifier: identifier} = field, %{identifier: objectId} = object) do
    # Logger.info "middleware: identifier: #{identifier}, objectId: #{objectId}"
    case objectId do
      :poem ->
	middleware
      _ ->
	new_middleware_spec = {{__MODULE__, :get_string_key}, Atom.to_string(identifier)}
	Absinthe.Schema.replace_default(middleware, new_middleware_spec, field, object)
    end
  end

  def get_string_key(%{source: source} = res, key) do
    %{res | state: :resolved, value: Map.get(source, key)}
  end
end
