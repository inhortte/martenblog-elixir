defmodule Martenblog.Transform do
  defmacro gemini do
    quote do 
      [
        %{
          dir: "flavigula",
          template: "music",
          geminis: [
            %{
              file: "allai",
              options: %{footnote_links: true}
            }, 
            %{
              file: "bons-mots",
              options: %{footnote_links: true}
            }, 
            %{
              file: "index",
              options: %{head_lop: 1, footnote_links: true}
            }, 
            %{
              file: "jemaraz",
              options: %{footnote_links: true}
            }, 
            %{
              file: "looptober-2020",
              options: %{footnote_links: true}
            }, 
            %{
              file: "omnivorous-expanse",
              options: %{footnote_links: true}
            }, 
            %{
              file: "releases",
              options: %{footnote_links: true}
            }, 
            %{
              file: "za-rohem",
              options: %{footnote_links: true}
            }, 
            %{
              file: "za-ruseni",
              options: %{footnote_links: true}
            }
          ]
        },
        %{
          dir: "recipes",
          template: "recipes",
          geminis: [
            %{
              file: "gofres",
              options: %{footnote_links: true}
            },
            %{
              file: "index",
              options: %{head_lop: 1, footnote_links: true}
            }
          ]
        },
        %{
          dir: "lakife",
          template: "lakife",
          geminis: [
            %{
              file: "babel-text",
              options: %{footnote_links: true}
            },
            %{
              file: "english-lakife",
              options: %{footnote_links: true}
            },
            %{
              file: "grammar",
              options: %{footnote_links: true}
            },
            %{
              file: "index",
              options: %{head_lop: 1, footnote_links: true}
            },
            %{
              file: "mihupola",
              options: %{footnote_links: true}
            },
            %{
              file: "phonemes",
              options: %{footnote_links: true}
            },
            %{
              file: "phrases",
              options: %{footnote_links: true}
            },
            %{
              file: "vocabulary",
              options: %{footnote_links: true}
            }
          ]
        }
      ]
    end
  end
end
