class Form
  enable_validate: ->
    $("form[data-validate]").enableClientSideValidations()

  select: ($select, args) ->
    @remove_old_select($select)

    select_args = {
      minimumResultsForSearch: -1,
      adaptDropdownCssClass: (c) ->
        if ("" + c) == "minimal_select"
          c
        else
          null
    }
    select_args.dropdownAutoWidth = true if $select.data("dropdown-auto-width")
    select_args = $.extend(select_args, args) if args
    $select.select2(select_args)
    $select.prev().find(".select2-arrow").after("<span class='sprites-pinkage-dropdown'></span>")

  remove_old_select: ($select) ->
    id = $select.attr("id")
    $("#s2id_" + id).remove()

app.form = new Form

$(document).on "history:updated", (e, element) ->
  app.form.enable_validate()

  $(element).find("select.select2").each (i, e) ->
    app.form.select($(e))

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

  $(document).on "form:validate:fail.ClientSideValidations", "form[data-validate]", ->
    alert($($(this).find("[data-error-message]").get(0)).data("error-message"))
