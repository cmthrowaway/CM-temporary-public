class PeerRatingsController < ResourceController::Base
  actions :vote_up, :vote_down
  
  # Create PeerRatings by POSTing to
  # /reviews/:review_id/peer_ratings/vote_up
  # /reviews/:review_id/peer_ratings/vote_down
  
  def vote_up
    create(PeerRating::VOTE_UP)
  end
  
  def vote_down
    create(PeerRating::VOTE_DOWN)
  end
  
  private
  def create(score)
    review = Review.find(params[:review_id])
    PeerRating.new do |pr|
      pr.review_id = review.id
      pr.user_id = current_user.id
      pr.score = score
    end.save!
    redirect_to company_url(review.company)
  end
  
end