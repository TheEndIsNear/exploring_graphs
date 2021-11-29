defmodule GraphCommons.Query do
  @enforce_keys ~w[data file type]a
  defstruct ~w[data file path type uri]a

  @type query_data :: String.t()
  @type query_file :: String.t()
  @type query_path :: String.t()
  @type query_type :: GraphCommons.query_type()
  @type query_uri :: String.t()

  @type t :: %__MODULE__{
          # user
          data: query_data,
          file: query_file,
          type: query_type,
          # system
          path: query_path,
          uri: query_uri
        }

  @storage_dir ".../query_commons/priv/storage"

  defguard is_query_type(query_type)
           when query_type in [:dquery, :native, :property, :rdf, :tinker]

  def new(query_data, query_file, query_type)
      when is_query_type(query_type) do
    query_path = "#{@storage_dir}/#{query_type}/queries/#{query_file}"

    %__MODULE__{
      # user
      data: query_data,
      file: query_file,
      type: query_type,
      # system
      path: query_path,
      uri: "file://" <> query_path
    }
  end

  def read_query(query_file, query_type)
      when query_file != "" and is_query_type(query_type) do
    querys_dir = "#{@storage_dir}/#{query_type}/querys/"
    query_data = File.read!(querys_dir <> query_file)

    new(query_data, query_file, query_type)
  end

  def write_query(query_data, query_file, query_type)
      when query_data != "" and query_file != "" and is_query_type(query_type) do
    querys_dir = "#{@storage_dir}/#{query_type}/querys/"
    File.write!(querys_dir <> query_file, query_data)

    new(query_data, query_file, query_type)
  end

  defimpl Inspect, for: __MODULE__ do
    @slice 16
    @quote <<?">>

    def inspect(%GraphCommons.Query{} = query, _opts) do
      type = query.type
      file = @quote <> query.file <> @quote

      str =
        query.data
        |> String.replace("\n", "\\n")
        |> String.replace(@quote, "\\" <> @quote)
        |> String.slice(0, @slice)

      data =
        case String.length(str) < @slice do
          true -> @quote <> str <> @quote
          false -> @quote <> str <> "..." <> @quote
        end

      "#GraphCommons.Query<type: #{type}, file: #{file}, data: #{data}>"
    end
  end
end
