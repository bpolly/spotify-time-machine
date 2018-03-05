module HeroColorHelper
  BULMA_COLORS = [
    'primary',
    'info',
    'success',
    'danger',
    'warning'
  ]

  def hero_color
    BULMA_COLORS.sample
  end
end
