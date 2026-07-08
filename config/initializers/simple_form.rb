# frozen_string_literal: true

#
# Uncomment this and change the path if necessary to include your own
# components.
# See https://github.com/heartcombo/simple_form#custom-components to know
# more about custom components.
# Dir[Rails.root.join('lib/components/**/*.rb')].each { |f| require f }
#
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  # Bulma wrapper for text/number/email/tel/date/time/file inputs.
  config.wrappers :default, class: "field" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "label"
    b.wrapper :control, tag: "div", class: "control" do |control|
      control.use :input, class: "input", error_class: "is-danger"
    end
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
  end

  # Bulma wrapper for textareas.
  config.wrappers :bulma_textarea, class: "field" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "label"
    b.wrapper :control, tag: "div", class: "control" do |control|
      control.use :input, class: "textarea", error_class: "is-danger"
    end
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
  end

  # Bulma wrapper for selects, which must be wrapped in a `.select` element.
  config.wrappers :bulma_select, class: "field" do |b|
    b.use :html5
    b.use :label, class: "label"
    b.wrapper :control, tag: "div", class: "control" do |control|
      control.wrapper :select, tag: "div", class: "select is-fullwidth" do |select|
        select.use :input, error_class: "is-danger"
      end
    end
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
  end

  # Bulma wrapper for checkboxes (nested label > input).
  config.wrappers :bulma_boolean, class: "field" do |b|
    b.use :html5
    b.wrapper :control, tag: "div", class: "control" do |control|
      control.use :label_input
    end
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
  end

  config.wrapper_mappings = {
    text: :bulma_textarea,
    select: :bulma_select,
    boolean: :bulma_boolean
  }

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  config.boolean_style = :nested

  # Default class for buttons
  config.button_class = "button is-primary"

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = "error_notification"

  # Series of attempts to detect a default label method for collection.
  # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

  # Series of attempts to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers. Defaulting to none.
  # config.collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to :span.
  # config.item_wrapper_tag = :span

  # You can define a class to use in all item wrappers. Defaulting to none.
  # config.item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  # config.label_text = lambda { |label, required, explicit_label| "#{required} #{label}" }

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = nil

  # You can define the default class to be used on forms. Can be overridden
  # with `html: { :class }`. Defaulting to none.
  # config.default_form_class = nil

  # You can define which elements should obtain additional classes.
  # Disabled: the Bulma wrappers above set every needed class explicitly, and the
  # auto-generated `select`/`optional` classes clash with Bulma (e.g. a stray
  # dropdown arrow on selects). Error/valid classes still come from the wrappers.
  config.generate_additional_classes_for = []

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Keep native HTML5 client-side validation enabled: the form must not carry the
  # `novalidate` option, so required/min/max/pattern/type attributes are enforced
  # by the browser (as they were before adopting SimpleForm).
  config.browser_validations = true

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = { string: :prepend }

  # Namespaces where SimpleForm should look for custom input classes that
  # override default inputs.
  # config.custom_inputs_namespaces << "CustomInputs"

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  # config.country_priority = nil

  # When false, do not use translations for labels.
  # config.translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  # config.inputs_discovery = true

  # Cache SimpleForm inputs discovery
  # config.cache_discovery = !Rails.env.development?

  # Default class for inputs
  # config.input_class = nil

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = "checkbox"

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  # config.include_default_input_wrapper_class = true

  # Defines which i18n scope will be used in Simple Form.
  # config.i18n_scope = 'simple_form'

  # Defines validation classes to the input_field. By default it's nil.
  # config.input_field_valid_class = 'is-valid'
  # config.input_field_error_class = 'is-invalid'
end
