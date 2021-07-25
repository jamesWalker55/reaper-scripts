local rv, audio_dir = reaper.GetSetProjectInfo_String(0, "RECORD_PATH", "test", false)

local rv = reaper.ShowMessageBox(audio_dir, "This is the audio files directory", 4)

reaper.ShowMessageBox(rv, "This is the return value", 0)