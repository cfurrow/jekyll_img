# Properties from user
# All methods are idempotent.
# attr_ methods can be called after compute_dependant_properties
# All methods except compute_dependant_properties can be called in any order
class ImgProperties
  attr_accessor :align, :alt, :attr_align_class, :attr_align_img, :caption, \
                :classes, :id, :nofollow, :src, :size, :style, :target, \
                :title, :url, :wrapper_class

  def attr_alt
    "alt='#{@alt}'" if @alt
  end

  def attr_img_classes
    @classes || 'imgImg rounded shadow'
  end

  def attr_id
    " id='#{@id}'" if @id
  end

  def attr_nofollow
    " rel='nofollow'" if @nofollow
  end

  def attr_size_class
    if @size == 'initial'
      'initial'
    elsif size_unit_specified?
      nil
    else
      @size
    end
  end

  def attr_style_img
    style = "max-width: #{@size};" if size_unit_specified?
    "style='#{style}#{@style}'" if @style || style
  end

  def attr_target
    return nil if @target == 'none'

    target = @target || '_blank'
    " target='#{target}'"
  end

  def attr_title
    "title='#{@title}'" if @title && !@title.empty?
  end

  def attr_width_caption
    "width: #{@size};" if size_unit_specified? && @caption
  end

  def attr_width_img
    "width: #{@size};" if size_unit_specified? && !@caption
  end

  def compute_dependant_properties
    setup_align
    setup_src

    @target ||= '_blank'

    @alt   ||= @caption || @title
    @title ||= @caption || @alt # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def src_png
    abort 'src parameter was not specified' if @src.to_s.empty?

    @src.gsub('.webp', '.png')
  end

  def self.local_path?(src)
    first_char = src[0]
    first_char.match?(%r{[./]})
  end

  private

  def setup_align
    if @align == 'center'
      @attr_align_img = 'center'
      @attr_align_class = @wrapper_class
    elsif @align
      @attr_align_img = @align
      @attr_align_class = "imgAlignDiv #{@align} #{@wrapper_class}"
    else
      @attr_align_img = 'inline'
      @attr_align_class = "imgAlignDiv #{@wrapper_class}"
    end
  end

  def setup_src
    @src = @src.to_s.strip
    abort 'src parameter was not specified' if @src.empty?

    @src = "/assets/images/#{@src}" unless ImgProperties.local_path?(@src) || url?(@src)
  end

  UNITS = %w[Q ch cm em dvh dvw ex in lh lvh lvw mm pc px pt rem rlh svh svw vb vh vi vmax vmin vw %].freeze

  def size_unit_specified?
    return false if @size.to_s.strip.empty?

    @size.end_with?(*UNITS)
  end

  def url?(src)
    src.start_with? 'http'
  end
end
