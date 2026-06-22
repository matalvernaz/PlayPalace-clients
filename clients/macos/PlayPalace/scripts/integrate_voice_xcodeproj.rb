#!/usr/bin/env ruby
# Idempotently wires voice chat into PlayPalace.xcodeproj (the project enumerates
# files explicitly and has no SPM deps, so new files + the LiveKit package must be
# registered here, not just in Package.swift). Run on the Mac build host:
#   ruby clients/macos/PlayPalace/scripts/integrate_voice_xcodeproj.rb
require "xcodeproj"

PROJECT = File.expand_path("../PlayPalace.xcodeproj", __dir__)
LIVEKIT_URL = "https://github.com/livekit/client-sdk-swift.git"
NEW_FILES = ["Sources/Audio/VoiceManager.swift"].freeze
MIC_USAGE = "PlayPalace uses your microphone for table voice chat.".freeze
# WebRTC references camera APIs (it's a full A/V stack) even though PlayPalace
# only uses voice, so Apple (ITMS-90683) requires a camera purpose string too.
CAMERA_USAGE = "PlayPalace voice chat does not use the camera; this key is required because its audio library references camera APIs.".freeze

project = Xcodeproj::Project.open(PROJECT)
target = project.targets.find { |t| t.name == "PlayPalace" } or abort("PlayPalace target not found")

# 1. LiveKit Swift SDK as an SPM package product on the target.
have_pkg = project.root_object.package_references.any? do |r|
  r.respond_to?(:repositoryURL) && r.repositoryURL.to_s.include?("client-sdk-swift")
end
unless have_pkg
  pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  pkg.repositoryURL = LIVEKIT_URL
  pkg.requirement = { "kind" => "upToNextMajorVersion", "minimumVersion" => "2.0.0" }
  project.root_object.package_references << pkg

  prod = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  prod.package = pkg
  prod.product_name = "LiveKit"
  target.package_product_dependencies << prod

  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = prod
  target.frameworks_build_phase.files << build_file
  puts "+ LiveKit package added"
end

# 2. Register any new source files not yet enumerated in the project.
NEW_FILES.each do |rel|
  next if project.files.any? { |f| f.path == rel }
  ref = project.main_group.new_reference(rel)
  ref.last_known_file_type = "sourcecode.swift"
  target.add_file_references([ref])
  puts "+ source file added: #{rel}"
end

# 3. Mic + camera usage strings for every build configuration.
target.build_configurations.each do |c|
  c.build_settings["INFOPLIST_KEY_NSMicrophoneUsageDescription"] = MIC_USAGE
  c.build_settings["INFOPLIST_KEY_NSCameraUsageDescription"] = CAMERA_USAGE
end

project.save
puts "xcodeproj updated."
