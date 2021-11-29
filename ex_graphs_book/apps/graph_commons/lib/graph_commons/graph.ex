defmodule GraphCommons.Graph do
  @enforce_keys ~w[data file type]a
  defstruct ~w[data file path type uri]a

  @type graph_data :: String.t()
  @type graph_file :: String.t()
  @type graph_path :: String.t()
  @type graph_type :: GraphCommons.graph_type()
  @type graph_uri :: String.t()

  @type t :: %__MODULE__{
          # user
          data: graph_data,
          file: graph_file,
          type: graph_type,
          # system
          path: graph_path,
          uri: graph_uri
        }

  @storage_dir ".../graph_commons/priv/storage"

  defguard is_graph_type(graph_type)
           when graph_type in [:dgraph, :native, :property, :rdf, :tinker]

  def new(graph_data, graph_file, graph_type)
      when is_graph_type(graph_type) do
    graph_path = "#{@storage_dir}/#{graph_type}/graphs/#{graph_file}"

    %__MODULE__{
      # user
      data: graph_data,
      file: graph_file,
      type: graph_type,
      # system
      path: graph_path,
      uri: "file://" <> graph_path
    }
  end

  defimpl Inspect, for: __MODULE__ do
    @slice 16
    @quote <<?">>

    def inspect(%GraphCommons.Graph{} = graph, _opts) do
      type = graph.type
      file = @quote <> graph.file <> @quote

      str =
        graph.data
        |> String.replace("\n", "\\n")
        |> String.replace(@quote, "\\" <> @quote)
        |> String.slice(0, @slice)

      data =
        case String.length(str) < @slice do
          true -> @quote <> str <> @quote
          false -> @quote <> str <> "..." <> @quote
        end

      "#GraphCommons.Graph<type: #{type}, file: #{file}, data: #{data}>"
    end
  end
end
