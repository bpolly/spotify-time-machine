module HeroColorHelper
  BULMA_COLORS = %w[
    primary
    info
    success
    danger
    warning
  ].freeze

  def hero_color
    BULMA_COLORS.sample
  end
end
