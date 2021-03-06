app = require 'core/application'
CocoCollection = require 'collections/CocoCollection'
CocoModel = require 'models/CocoModel'
Courses = require 'collections/Courses'
Campaigns = require 'collections/Campaigns'
Classroom = require 'models/Classroom'
Classrooms = require 'collections/Classrooms'
User = require 'models/User'
CourseInstance = require 'models/CourseInstance'
RootView = require 'views/core/RootView'
template = require 'templates/courses/teacher-courses-view'
HeroSelectModal = require 'views/courses/HeroSelectModal'

module.exports = class TeacherCoursesView extends RootView
  id: 'teacher-courses-view'
  template: template

  events:
    'click .guide-btn': 'onClickGuideButton'
    'click .play-level-button': 'onClickPlayLevel'

  guideLinks:
    {
      "560f1a9f22961295f9427742":
        python: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_intro_python.pdf'
        javascript: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_intro_javascript.pdf'
      "5632661322961295f9428638":
        python: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_course-2_python.pdf'
        javascript: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_course-2_javascript.pdf'
      "56462f935afde0c6fd30fc8c":
        python: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_course-3_python.pdf'
        javascript: 'http://files.codecombat.com/teacherguides/CodeCombat_TeacherGuide_course-3_javascript.pdf'
      "56462f935afde0c6fd30fc8d": null
      "569ed916efa72b0ced971447": null
    }

  getTitle: -> return $.i18n.t('teacher.courses')

  constructor: (options) ->
    super(options)
    @ownedClassrooms = new Classrooms()
    @ownedClassrooms.fetchMine({data: {project: '_id'}})
    @supermodel.trackCollection(@ownedClassrooms)
    @courses = new Courses()
    if me.isAdmin()
      @supermodel.trackRequest @courses.fetch()
    else
      @supermodel.trackRequest @courses.fetchReleased()
    @campaigns = new Campaigns()
    @supermodel.trackRequest @campaigns.fetchByType('course', { data: { project: 'levels,levelsUpdated' } })
    @

  initialize: (options) ->
    window.tracker?.trackEvent 'Classes Guides Loaded', category: 'Teachers', ['Mixpanel']
    super(options)

  onClickGuideButton: (e) ->
    courseID = $(e.currentTarget).data('course-id')
    courseName = $(e.currentTarget).data('course-name')
    eventAction = $(e.currentTarget).data('event-action')
    window.tracker?.trackEvent eventAction, category: 'Teachers', courseID: courseID, courseName: courseName, ['Mixpanel']

  onClickPlayLevel: (e) ->
    form = $(e.currentTarget).closest('.play-level-form')
    levelSlug = form.find('.level-select').val()
    courseID = form.data('course-id')
    language = form.find('.language-select').val() or 'javascript'
    window.tracker?.trackEvent 'Classes Guides Play Level', category: 'Teachers', courseID: courseID, language: language, levelSlug: levelSlug, ['Mixpanel']
    url = "/play/level/#{levelSlug}?course=#{courseID}&codeLanguage=#{language}"
    firstLevelSlug = @campaigns.get(@courses.at(0).get('campaignID')).getLevels().at(0).get('slug')
    if levelSlug is firstLevelSlug
      @listenToOnce @openModalView(new HeroSelectModal()),
        'hidden': ->
          application.router.navigate(url, { trigger: true })
    else
      application.router.navigate(url, { trigger: true })
