class ProductsReviewsState
  constructor: ->
    @appended_callback = (e, element) ->
      app.reviews.handle_link_expand({elements: $(element)}, false)

  on_enter: (old_state_name, args) ->
    app.reviews.handle_link_expand(args, false)
    @set_position_options()
    @set_app_product_info(args)
    @bind_nonmember_review_hint()
    @bind_scroll(args.elements.find("#lista"))
    $(document).on "infinite_scroll:appended", @appended_callback

  on_exit: ->
    $(document).off "infinite_scroll:appended", @appended_callback

  set_app_product_info: (args) ->
    @app_product_info = new AppProductInfo(args) if app.widget.is_new_tab()

  set_position_options: ->
    $review_option_search = $(".review-options-search")
    if $review_option_search.hasClass("hidden")
      $review_option_search.removeClass("hidden")
      $(".review-options-search").addClass("hidden")

  refresh_filter: ->
    url_builder = new UrlBuilder(lib.history.get_current_url())
    url_builder.remove_param("page")
    url_builder.add_param("aloading", ".page")
    url_builder.add_param("atarget", "reviews")

    $score_summary = $(".score-summary")

    scores = []
    $score_summary.find("li.selected").each (i, element) ->
      scores.push($(element).data("score"))

    if scores.length > 0
      url_builder.add_param("scores", JSON.stringify(scores))
    else
      url_builder.remove_param("scores")

    $link_photo_reviews = $score_summary.find("a.link-photo-reviews")
    if $link_photo_reviews.hasClass("selected")
      url_builder.add_param("filter", $link_photo_reviews.data("filter"))
    else
      url_builder.remove_param("filter")

    $.getScript url_builder.build()

  on_focus: ($form) ->
    $textarea = $form.find("textarea.new-review-form")
    return if $textarea.data("triggered")
    $textarea.data("triggered", true)

    $review_option_fields = $form.find(".review-option-fields")
    if $review_option_fields.length > 0
      # IE7에서 .show() 대신 .css(display: "block")을 해줘야됨. 이유는 모름.
      # https://app.asana.com/0/80420144146943/91330956610548
      $review_option_fields.css(marginTop: -($review_option_fields.height() + 50), opacity: 0, display: "block")
      if Modernizr.cssanimations
        setTimeout (->
          $review_option_fields.addClass("anim")
          $review_option_fields.css(marginTop: 0)
          setTimeout (->
            $review_option_fields.css(opacity: 1)
            ), 200
          ), 0
      else
        setTimeout (->
          $review_option_fields.animate {marginTop: 0}, 200, lib.animation.ease_out
          setTimeout (->
            $review_option_fields.animate {opacity: 1}, 200, lib.animation.ease_out
            ), 200
          ), 0

    $nonmember_review_tmpl = $("#nonmember-review-tmpl")
    if $nonmember_review_tmpl.length > 0
      $nonmember_review = $($nonmember_review_tmpl.html())
      $nonmember_review.find("#review_user_name").attr("autocomplete", "off")
      $nonmember_review.find("#review_password").attr("autocomplete", "off")
      $form.prepend($nonmember_review)
      if Modernizr.cssanimations
        setTimeout (->
          $nonmember_review.css(top: 0)
          $form.find(".message-field").css("padding-top": 77)
          setTimeout (->
            $nonmember_review.find(".content-container").css(opacity: 1)
            ), 300
          ), 0
      else
        setTimeout (->
          $nonmember_review.animate {top: 0}, 300, lib.animation.ease_out
          $form.find(".message-field").animate {"padding-top": 77}, 300, lib.animation.ease_out
          setTimeout (->
            $nonmember_review.find(".content-container").animate {opacity: 1}, 200
            ), 300
          ), 0
      lib.animation.animate($form.addClass("show-nonmember-review"))

      $form.find("#review_user_name").focus()

      $form.bind "ajax:before", ->
        $input = $form.find("#review_user_name")
        if !$input.val()
          alert($input.data("presence-warning"))
          return false

        $input = $form.find("#review_password")
        if !$input.val()
          alert($input.data("presence-warning"))
          return false

    $review_policy_tmpl = $("#review-policy-tmpl")
    if $review_policy_tmpl.length > 0
      $review_policy = $($review_policy_tmpl.html())
      $form.prepend($review_policy)
      if Modernizr.cssanimations
        setTimeout (->
          $review_policy.css(top: 0)
          $form.find(".message-field").css("padding-top": 73)
          setTimeout (->
            $review_policy.find(".content-container").css(opacity: 1)
            ), 300
          ), 0
      else
        setTimeout (->
          $review_policy.animate {top: 0}, 300, lib.animation.ease_out
          $form.find(".message-field").animate {"padding-top": 73}, 300, lib.animation.ease_out
          setTimeout (->
            $review_policy.find(".content-container").animate {opacity: 1}, 200
            ), 300
          ), 0

      $view_detail = $(".view-detail")
      $("#review-policy-detail").remove()
      $review_policy_detail = null
      $view_detail.on "mouseenter", ->
        if !$review_policy_detail
          $review_policy_detail = $("<div id='review-policy-detail'></div>").html($("#review-policy-detail-tmpl").html()).appendTo("body")
          popup_bottom = $review_policy_detail.height() + 100
          if popup_bottom > $(window).height()
            app.window.set_height(popup_bottom)

        if Modernizr.cssanimations
          $review_policy_detail.addClass("hover")
        else
          $review_policy_detail.
            show().
            animate({top: 45}, 0, lib.animation.ease_out).
            animate({opacity: 1}, 0)

      $view_detail.on "mouseleave", ->
        if Modernizr.cssanimations
          $review_policy_detail.removeClass("hover")
        else
          $review_policy_detail.
            animate({top: 30}, 0, lib.animation.ease_out).
            animate({opacity: 0}, 0)
          setTimeout (->
            $review_policy_detail.hide()
          ), 100

  bind_form: ($form) ->
    app.review_image.set_form($form)
    $textarea = $form.find("textarea.new-review-form")
    $textarea.off "focus"
    not_creatable_reason = $form.data('not-creatable-reason')
    if not_creatable_reason
      $textarea.on "focus", ->
        if !$textarea.data("login-required") || lib.data.get("username")
          $this = $(this)
          $this.blur()
          alert(not_creatable_reason)
          false
    else if $form.data("already-posted")
      if lib.data.get("allow-multiple-reviews-per-product")
        ignore_once = false
        $textarea.one "focus", (e) =>
          if confirm($form.data("already-posted"))
            @on_focus($form)
            result = true
          else
            $(e.target).blur()
            result = false

          result
      else
        $textarea.on "focus", ->
          $this = $(this)
          $this.blur()
          alert(lib.i18n.t("review_already_posted"))
          false
    else
      $textarea.on "focus", (e) =>
        if !$textarea.data("login-required") || lib.data.get("username")
          @on_focus($form)

  bind_nonmember_review_hint: ->
    return if lib.browser.supports_media_query()
    set_hint_visibility = ->
      $hint = $(".nonmember_review__hint")
      if $(window).width() > 940
        $hint.show()
      else
        $hint.hide()

    $(window).resize -> set_hint_visibility()
    set_hint_visibility()

  bind_scroll: ($list) ->
    $list.als
      visible_items: 5
      scrolling_items: 5
      orientation: "horizontal"
      circular: "yes"
      autoscroll: "yes"
      interval: 4000
      direction: "left"

app.products_reviews_state = new ProductsReviewsState

$(document).on "history:updated", (e, element) ->
  $element = $(element)
  $form = $element.find("#form-new-product-review").addBack("#form-new-product-review")
  app.products_reviews_state.bind_form($form) if $form.length

  $element.find(".show-reviews-index").click ->
    app.window.redirect_to $(this).data("reviews-index-url")

  $element.find("a.link-score").click (e) ->
    $link = $(e.currentTarget)
    $link.closest("li").toggleClass("selected")
    app.products_reviews_state.refresh_filter()

  $element.find("a.link-photo-reviews").click (e) ->
    $(e.currentTarget).toggleClass("selected")
    app.products_reviews_state.refresh_filter()

  $element.find("a.review-options-search-toggle").click ->
    $this = $(this)
    if $this.hasClass("searching")
      $this.removeClass("searching")
    else
      $this.addClass("searching")

    $option_search_bar = $(".review-options-search")
    if $option_search_bar.hasClass("hidden")
      $option_search_bar.removeClass("hidden")
      lib.animation.height_up $option_search_bar
    else
      lib.animation.height_down $option_search_bar, -> $option_search_bar.addClass("hidden")
