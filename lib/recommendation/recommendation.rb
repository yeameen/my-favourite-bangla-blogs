
class Recommendation
  def self.similarity_pearson(p_preferences, p_person1, p_person2)
    similarities = []
    p_preferences[p_person1].each_key do |item|
      if p_preferences[p_person2].include?(item)
        similarities.push(item)
      end
    end
    common_items_length = similarities.length()

    return 0.0 if common_items_length == 0

    sum_person1 = 0.0
    sum_person2 = 0.0
    sum_of_squares_person1 = 0.0
    sum_of_squares_person2 = 0.0
    sum_of_products = 0.0
    similarities.each do |item|
      sum_person1 += p_preferences[p_person1][item]
      sum_person2 += p_preferences[p_person2][item]

      sum_of_squares_person1 += p_preferences[p_person1][item] ** 2
      sum_of_squares_person2 += p_preferences[p_person2][item] ** 2

      sum_of_products += p_preferences[p_person1][item] * p_preferences[p_person2][item]
    end
    # calculate person score
    num = sum_of_products - (sum_person1 * sum_person2 / common_items_length)
    density = Math::sqrt((sum_of_squares_person1 - (sum_person1 ** 2)/common_items_length) * (sum_of_squares_person2 - (sum_person2 ** 2) / common_items_length))
    return 0.0 if density == 0

    return num / density
  end

  def self.top_matches(p_preferences, p_person, p_num_matches = 5)
    scores = {}
    for other in p_preferences.keys
      if other != p_person
        "similarity between #{p_person} and #{other} - "
        scores.merge!(similarity_pearson(p_preferences, p_person, other) => other)
      end
      nil
    end
    result_array = scores.sort_by{|key, value| key}.reverse[0..p_num_matches-1]
    result_hash = result_array.inject({}) do |temp_hash, value|
      temp_hash[value.first] = value.last
      temp_hash
    end
    return result_hash.sort.reverse
  end

  def self.get_recommendations(p_preferences, p_person)
#    puts "Person - #{p_person}, preferences - #{p_preferences[p_person].inspect}\n"
    totals = Hash.new(0)
    similaritySums = Hash.new(0)

    p_preferences.each do |other, preferences|
      # don't compare to myself
      if other != p_person
        similarity = similarity_pearson(p_preferences, p_person, other)

        # if positive similarity
        if similarity > 0
          # find the items not in p_person's list
          for item, value in p_preferences[other]
            if !p_preferences[p_person].has_key?(item) or (p_preferences[p_person].has_key?(item) && p_preferences[p_person][item] == 0.0)
#              puts "for person - #{p_person}, calculating recommendation for - #{item}"
              totals[item] += p_preferences[other][item] * similarity
              similaritySums[item] += similarity
            end
          end
        end
      end
    end

    rankings = []
    totals.each do |item, total|
      rankings << [total/similaritySums[item], item]
    end
    return rankings.sort.reverse
  end

  def self.get_recommendations_from_array(p_preferences_array, p_person)
    preferences_hash = array_to_hash(p_preferences_array)
    return get_recommendations(preferences_hash, p_person)
  end

  def self.transform_preferences(p_preferences)
    reverse_preferences = Hash.new()
    p_preferences.each do |person, ratings|
      ratings.each do |item, rating|
        reverse_preferences[item] = {} unless reverse_preferences.has_key?(item)
        reverse_preferences[item][person] = rating
      end
    end
    return reverse_preferences
  end

  def self.array_to_hash(p_array)
    hashmap = Hash.new()
    item_hashmap = {}
    p_array.each do |name, values|
      hashmap[name] = values.inject({}) do |temp_hash, key|
        temp_hash[key] = 1.0
        item_hashmap[key] = 1
        temp_hash
      end
    end

    # fill other values
    hashmap.each do |name, ratings|
      item_hashmap.each do |key, value|
        ratings[key] = 0.0 unless ratings.has_key?(key)
      end
    end

    return hashmap
  end
end
