class Form
  enable_validate: ->
    $("form[data-validate]").enableClientSideValidations()

  select: ($select, args) ->
    applied_key = "select2-applied"
    return if $select.data(applied_key)
    $select.data(applied_key, true)

    select_args = {minimumResultsForSearch: -1}
    select_args = $.extend(select_args, args) if args

    $select.select2(select_args)
    $select.prev().find(".select2-arrow").after("<i class='fa fa-angle-down'></i>")
    $select.on "select2-focus", (e) ->
      $("input[type='text'], textarea").blur()

app.form = new Form

$(document).on "history:updated", (e, element) ->
  app.form.enable_validate()

  $(element).find("select.select2").each (i, e) ->
    app.form.select($(e))

$(document).on "history:loaded", ->
  $(".select2-container").remove()

$ ->
  $(document).on lib.ui_util.textchange_events, ".count-limit", (e) ->
    $input = $(this)
    $limit_counter = $input.closest(".limit-count-container").find(".limit-counter")
    val = $input.val()
    maxlength = parseInt($input.attr("maxlength"))
    # exclude space
    if $input.data("up-counter")
      count = val.replace(/\s/g, "").length
    else
      count = maxlength - val.replace(/\s/g, "").length

    if count >= 0
      $limit_counter.html(count)
    else
      if $.browser.msie
        $input.val(val.substr(0, maxlength))
      $limit_counter.html(0)
