if not tweak_data.music.track_list and not tweak_data.music.track_menu_list then
	tweak_data.music.track_list = {}
	tweak_data.music.track_menu_list = {}

	local music_tracks = MusicManager.jukebox_music_tracks
	function MusicManager:jukebox_music_tracks()
		local tracks, locked = music_tracks(self)

		for _, data in ipairs(tweak_data.music.track_list) do
			table.insert(tracks, data.track)
			table.insert(locked, data.lock)
		end

		return tracks, locked
	end

	local menu_tracks = MusicManager.jukebox_menu_tracks
	function MusicManager:jukebox_menu_tracks()
		local tracks, locked = menu_tracks(self)

		for _, data in ipairs(tweak_data.music.track_menu_list) do
			table.insert(tracks, data.track)
			table.insert(locked, data.lock)
		end

		return tracks, locked
	end
end