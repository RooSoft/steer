import Ecto.Query

alias Steer.Repo, as: Repo
alias Steer.Lightning.Models, as: Models

channels = Repo.get_all_channels
