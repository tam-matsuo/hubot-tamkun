# Description:
#   backlog-api
#
# Commands:
#
cron = require('cron').CronJob

intervalMinutes = 5
backlogUrl = 'https://testam.backlog.jp/'
apiKey = 'dbANbPdA9hQuWMWJ7dHxHCWjaPI6a4lHB8SHgqe2ItN2DOwcYOO4pDyjKdMARJ3w'


module.exports = (robot) ->

	webhookPost = (data) ->
		robot.http("https://hooks.slack.com/services/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")
		.post(JSON.stringify data) (err, res, body) ->
			console.log body


	new cron "0 */#{intervalMinutes} * * * *", ->

		postData = []
		
		# APIアクセス
		robot.http("#{backlogUrl}api/v2/space/activities?apiKey=#{apiKey}")
		.get() (err, res, body) ->

			# 前回Cron実行時刻
			lastTime = new Date - intervalMinutes*60*1000

			for feed in JSON.parse body

				# 前回のCron実行時刻より古いものは処理しない
				if new Date(feed.created) < lastTime
					continue

				# 出力
				prj = feed.project.projectKey
				username = feed.createdUser.name
				webhookUser = 'backlog'
				icon_url = 'http://nulab-inc.com/assets/img/home/img_apps_backlog.png'
				more = ''

				switch feed.type
				# 課題
					when 1,2,3
						url = "#{backlogUrl}view/#{prj}-#{feed.content.key_id}"
						if feed.content.comment?.id?
							url += "#comment-#{feed.content.comment.id}"

						title = "#{feed.content.summary}"

						switch feed.type
							when 1
								label = '課題追加'
							when 2
								label = '課題更新'
							else
								label = '課題コメント'

					# wiki
					when 5, 6
						url = "#{backlogUrl}alias/wiki/#{feed.content.id}"
						label = 'Wiki' + if feed.type == 5 then '追加' else '更新'
						title = "#{feed.content.name}"

					# git push
					when 12
						repo = feed.content.repository
						label = "#{feed.content.change_type}"
						ref = feed.content.ref.match(/[^\/]+$/)[0]
						title = "#{repo.name} #{ref}"

						webhookUser = 'backlog-git'
						icon_url = 'http://msysgit.github.io/img/git_logo.png'

						if feed.content.revision_count > 0
							url = "#{backlogUrl}git/#{prj}/#{repo.name}/commit/#{feed.content.revisions[0].rev}"
							more = " '#{feed.content.revisions[0].comment}'"
						else
							url = "#{backlogUrl}git/#{prj}/#{repo.name}"

					else
						continue

				# create slack post data
				text = "[#{prj}] #{label} - #{title}#{more} by #{username} <#{url}>"
				postData[text] =
					text: text
					username: webhookUser
					icon_url: icon_url
					channel: '#notify'

			# post to slack
			for key, obj of postData
				webhookPost obj

	, null, true, 'Asia/Tokyo'
