class SearchesController < ApplicationController
  layout false

  RESULTS_LIMIT = 20

  def reservations
    @query = params[:q].to_s.strip
    @include_past = ActiveModel::Type::Boolean.new.cast(params[:include_past])
    @reservations = matching_reservations
  end

  private

  def matching_reservations
    return Reservation.none if @query.blank?

    scope = Reservation.includes(group: :event)
                       .references(:group)
                       .where("lower(reservations.full_name) LIKE lower(?)", "%#{@query}%")
                       .order(Arel.sql("groups.date DESC, groups.time DESC"))
    scope = scope.where(groups: { date: Date.current.. }) unless @include_past
    scope.to_a.select { |reservation| @include_past || reservation.group.upcoming? }.first(RESULTS_LIMIT)
  end
end
