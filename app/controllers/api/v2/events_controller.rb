module Api::V2
  class EventsController < ApiController
    def create
      Rails.logger.info "event:#{params[:name]} - #{current_user&.id} | #{anonymous_id} --------------------"
      track
      vote if params[:name] == "vote" && current_user.present?
      head :ok
    end

    private

    def vote
      Agreement.create!(statement_id: params[:statement_id], individual: current_user, extent: params[:extent])
    end

    def track
      statement = Statement.find_by(id: params[:statement_id])
      individual = Individual.find_by(id: params[:game_individual_id])
      Analytics.track(
        user_id: current_user&.id,
        anonymous_id: anonymous_id,
        event: params[:name],
        properties: {
          statement: statement&.content,
          game_individual: individual&.visible_name,
          extent: params[:extent]
        }
      )
    end
  end
end
