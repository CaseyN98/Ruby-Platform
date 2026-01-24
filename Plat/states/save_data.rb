require "json"

class SaveData
  FILE = "save_data.json"

  def self.load
    if File.exist?(FILE)
      JSON.parse(File.read(FILE))
    else
      {}
    end
  end

  def self.save(data)
    File.write(FILE, JSON.pretty_generate(data))
  end

  #
  # Update best score for a map
  #
def self.update_level(level_name, time:, stars:, total_stars:)
  data = load

  best = data[level_name] || {
    "time" => nil,
    "stars" => 0,
    "total_stars" => total_stars
  }

  # Update best time
  if best["time"].nil? || time < best["time"]
    best["time"] = time
  end

  # Update best stars
  if stars > best["stars"]
    best["stars"] = stars
  end

  # Always store total stars (in case level changes)
  best["total_stars"] = total_stars

  data[level_name] = best
  save(data)
end

  #
  # Get best score for a map
  #
  def self.get(level_name)
    load[level_name] || { "time" => nil, "stars" => 0 }
  end
end