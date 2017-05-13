class DistrictPresident
  def initialize(pastors)
    @pastors = pastors
  end

  def candidate_list(parish)
    # Offer four candidates
    reasons = {}
    @pastors.select do |pastor|
      eligible = pastor.eligible?(parish)
      if eligible == true
        true
      else
        reasons[eligible] ||= 0
        reasons[eligible] += 1
        false
      end
    end.shuffle[0..3].tap do |list|
      next if list.any?
      # puts 'No eligible candidates. Reasons:'
      # reasons.each do |reason, count|
      #   puts "#{reason}: #{count}"
      # end
    end
  end
end
