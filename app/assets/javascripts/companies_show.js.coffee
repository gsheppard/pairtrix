namespace "Pairtrix", (exports) ->
  class exports.CompaniesShow
    draggableParams =
      revert: true
      zIndex: 300

    init: ->
      $("#employee").on "show", ->
        CompaniesShow.resetForm $(this).find("form")

      $("#team").on "show", ->
        CompaniesShow.resetForm $(this).find("form")

      $("#team_ajax").on "submit", ->
        form = $(this)
        formData = new FormData(form[0])
        CompaniesShow.removeErrors form
        $.ajax
          url: form.attr("action")
          type: "POST"
          beforeSend: (xhr) ->
            xhr.setRequestHeader "Accept", "application/json"

          statusCode:
            201: (team) ->
              CompaniesShow.addTeam team
              $("#team").modal "hide"

            202: (team) ->
              CompaniesShow.updateTeam team
              $("#team").modal "hide"

          error: (result) ->
            CompaniesShow.displayErrors "team", form, result

          data: formData
          cache: false
          contentType: false
          processData: false
        false

      $("#team-submit").on "click", (e) ->
        e.preventDefault()
        $("#team_ajax").submit()

      $("#employee_ajax").on "submit", ->
        form = $(this)
        formData = new FormData(form[0])
        CompaniesShow.removeErrors form
        $.ajax
          url: form.attr("action")
          type: "POST"
          beforeSend: (xhr) ->
            xhr.setRequestHeader "Accept", "application/json"

          statusCode:
            201: (employee) ->
              CompaniesShow.addEmployee employee
              $("#employee").modal "hide"

            202: (employee) ->
              CompaniesShow.updateEmployee employee
              $("#employee").modal "hide"

          error: (result) ->
            CompaniesShow.displayErrors "employee", form, result

          data: formData
          cache: false
          contentType: false
          processData: false

        false

      $("#employee-submit").on "click", (e) ->
        e.preventDefault()
        $("#employee_ajax").submit()

      $(".available-employees li").draggable draggableParams
      $(".team li").draggable draggableParams
      $(".team ul").droppable
        accept: ".available-employee, .team-membership"
        hoverClass: "ui-hover"
        drop: (event, ui) ->
          CompaniesShow.createTeamMembership $(ui.draggable[0]), $(this)

      $(".available-employees ul").droppable
        accept: ".team-membership"
        hoverClass: "ui-hover"
        drop: (event, ui) ->
          CompaniesShow.createAvailableEmployee $(ui.draggable[0]), $(this)

      $.contextMenu
        selector: ".team h5"
        items:
          edit:
            name: "Edit Team"
            callback: (key, opt) ->
              CompaniesShow.editTeam opt

            icon: "edit"

          delete:
            name: "Delete Team"
            callback: (key, opt) ->
              CompaniesShow.deleteTeam opt

            icon: "delete"

      $.contextMenu
        selector: ".employee-badge"
        items:
          edit:
            name: "Edit Employee"
            callback: (key, opt) ->
              CompaniesShow.editEmployee opt
            icon: "edit"

          delete:
            name: "Delete Employee"
            callback: (key, opt) ->
              CompaniesShow.deleteEmployee opt
            icon: "delete"

    @getEmployeeId: (element) ->
      element.find(".employee-badge").data "employee-id"

    @unableToCompleteAction: ->
      $("#flash-messages").html("<div class='alert alert-error'>Unable to complete that operation.</div>").show().delay(2000).fadeOut "fast"

    @addAvailableEmployee: (teamMembership, availableEmployees) ->
      cssClasses = CompaniesShow.updateClasses(false)
      teamMembership.remove().clone(true).css("position", "inherit").addClass(cssClasses.addClass).removeClass(cssClasses.removeClass).removeAttr("style").appendTo(availableEmployees).draggable draggableParams

    @addTeamMember: (employee, team, teamMembershipId) ->
      cssClasses = CompaniesShow.updateClasses(true)
      employee.remove().clone(true).css("position", "inherit").addClass(cssClasses.addClass).removeClass(cssClasses.removeClass).removeAttr("style").data("team-membership-id", teamMembershipId).appendTo(team).draggable draggableParams

    @createAvailableEmployee: (teamMembership, availableEmployees) ->
      teamMembershipId = teamMembership.data("team-membership-id")
      $.post("/team_memberships/#{teamMembershipId}",
        format: "json"
        _method: "delete"
      , ->
        CompaniesShow.addAvailableEmployee teamMembership, availableEmployees
      ).error ->
        CompaniesShow.unableToCompleteAction()

    @createTeamMembership: (employee, team) ->
      teamId = team.closest(".team").data("team-id")
      employeeId = CompaniesShow.getEmployeeId(employee)
      $.post("/teams/#{teamId}/team_memberships",
        "team_membership[employee_id]": employeeId
        format: "json"
      , (teamMembership) ->
        CompaniesShow.addTeamMember employee, team, teamMembership.id
      ).error ->
        CompaniesShow.unableToCompleteAction()

    @addTeam: (team) ->
      teamHtml = $("<div/>",
        class: "team"
        "data-team-id": team.id
      ).data("team-id", team.id).html($("<div/>",
        class: "heading"
      ).html($("<h5/>").html($("<a/>",
        text: team.name
        href: "/teams/#{team.id}"
      )))).append($("<ul/>",
        class: "team-memberships ui-droppable"
      ).droppable(
        accept: ".available-employee, .team-membership"
        hoverClass: "ui-hover"
        drop: (event, ui) ->
          CompaniesShow.createTeamMembership $(ui.draggable[0]), $(this)
      ))
      $(".team").parent().append teamHtml

    @updateTeam: (team) ->
      companyId = $("h3").data("company-id")
      $(".team[data-team-id='#{team.id}'] h5 a").text team.name
      $("#team_ajax").attr "action", "/companies/#{companyId}/teams"
      $("#team_ajax").find("input[name='_method']").remove()
      $("#teamLabel").text "Add Team"
      $("#team-submit").text "Add Team"

    @addEmployee: (employee) ->
      fullName = "#{employee.first_name} #{employee.last_name}"
      imageUrl = employee.avatar.url or "/assets/layout/avatar.png"
      employeeHtml = $("<li/>",
        class: "available-employee ui-draggable"
      ).html($("<div/>",
        class: "employee-badge badge"
        "data-employee-id": employee.id
      ).data("employee-id", employee.id).html($("<div/>",
        class: "avatar"
      ).html($("<img/>",
        alt: fullName
        src: imageUrl
      ))).append($("<div/>",
        class: "employee-name"
        text: fullName
      ))).draggable(draggableParams)
      $(".available-employees").find("ul").append employeeHtml

    @updateEmployee: (employee) ->
      companyId = $("h3").data("company-id")
      fullName = "#{employee.first_name} #{employee.last_name}"
      imageUrl = employee.avatar.url or "/assets/layout/avatar.png"
      badge = $(".employee-badge[data-employee-id='#{employee.id}']")
      badge.find("img").attr("src", imageUrl).attr "alt", fullName
      badge.find(".employee-name").text fullName
      $("#employee_ajax").attr "action", "/companies/#{companyId}/employees"
      $("#employee_ajax").find("input[name='_method']").remove()
      $("#employeeLabel").text "Add Employee"
      $("#employee-submit").text "Add Employee"

    @addError: (prefix, field, message) ->
      inputField = $("##{prefix}_#{field}")
      inputField.closest(".form-group").addClass "has-error"
      inputField.closest(".controls").append $("<span/>",
        class: "help-block"
        text: message
      )

    @displayErrors: (modelName, form, result) ->
      errors = $.parseJSON(result.responseText).errors
      $.each errors, (field, message) ->
        CompaniesShow.addError modelName, field, message

    @removeErrors: (form) ->
      controlGroup = form.find(".control-group")
      controlGroup.removeClass "error"
      controlGroup.find(".controls").each ->
        $(this).find("span").remove()

    @resetForm: (form) ->
      form[0].reset()
      CompaniesShow.removeErrors form

    @deleteTeam: (options) ->
      team = options.$trigger.closest(".team")
      teamId = team.data("team-id")
      if confirm("Are you sure?")
        $.ajax
          url: "/teams/#{teamId}"
          type: "POST"
          beforeSend: (xhr) ->
            xhr.setRequestHeader "Accept", "application/json"
          success: ->
            availableEmployees = $(".available-employees ul")
            $(team).find(".team-membership").each ->
              CompaniesShow.addAvailableEmployee $(this), availableEmployees
            $(team).remove()
          data:
            _method: "DELETE"

    @deleteEmployee: (options) ->
      employee = options.$trigger
      employeeId = employee.data("employee-id")
      if confirm("Are you sure?")
        $.ajax
          url: "/employees/#{employeeId}"
          type: "POST"
          beforeSend: (xhr) ->
            xhr.setRequestHeader "Accept", "application/json"
          success: ->
            $(employee).remove()
          data:
            _method: "DELETE"

    @editEmployee: (options) ->
      employee = options.$trigger
      employeeId = employee.data("employee-id")
      $.ajax
        url: "/employees/#{employeeId}/edit"
        type: "GET"
        beforeSend: (xhr) ->
          xhr.setRequestHeader "Accept", "application/json"
        success: (employee) ->
          $("#employee_ajax").attr "action", "/employees/#{employee.id}"
          $("#employee_ajax").find("input[name='authenticity_token']").append $("<input/>",
            type: "hidden"
            name: "_method"
            value: "put"
          )
          $("#employeeLabel").text "Edit Employee"
          $("#employee-submit").text "Update Employee"
          $("#employee").modal "show"
          $("#employee_first_name").val employee.first_name
          $("#employee_last_name").val employee.last_name
          $("#employee_do_not_pair").val employee.do_not_pair.toString()

    @editTeam: (options) ->
      team = options.$trigger.closest(".team")
      teamId = team.data("team-id")
      $.ajax
        url: "/teams/#{teamId}/edit"
        type: "GET"
        beforeSend: (xhr) ->
          xhr.setRequestHeader "Accept", "application/json"
        success: (team) ->
          $("#team_ajax").attr "action", "/teams/#{team.id}"
          $("#team_ajax").find("input[name='authenticity_token']").append $("<input/>",
            type: "hidden"
            name: "_method"
            value: "put"
          )
          $("#teamLabel").text "Edit Team"
          $("#team-submit").text "Update Team"
          $("#team").modal "show"
          $("#team_name").val team.name

    @updateClasses: (newTeam) ->
      if newTeam is true
        addClass = "team-membership"
        removeClass = "available-employee"
      else
        addClass = "available-employee"
        removeClass = "team-membership"
      addClass: addClass
      removeClass: removeClass
