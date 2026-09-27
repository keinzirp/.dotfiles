class KakounePatched < Formula
  desc "Selection-based modal text editor with Zellij shifted-Alt fallback"
  homepage "https://github.com/mawww/kakoune"
  url "https://github.com/mawww/kakoune/releases/download/v2026.05.21/kakoune-2026.05.21.tar.bz2"
  sha256 "be1deb3fe9808a0733ab1057309da380bb757307e8fdbb22dc478b674b6bad34"
  license "Unlicense"
  head "https://github.com/mawww/kakoune.git", branch: "master"

  conflicts_with "kakoune", because: "both install the kak executable"

  # Zellij does not provide Kitty's alternate-key enhancement.
  # https://github.com/zellij-org/zellij/issues/3789
  patch :p1, File.read(File.join(__dir__, "..", "Patches", "kakoune-zellij-shifted-alt.patch"))


  def install
    system "make", "install", "debug=no", "PREFIX=#{prefix}"
  end

  test do
    system bin/"kak", "-ui", "dummy", "-e", "q"

    assert_match "Kakoune ", shell_output("#{bin}/kak -version")
  end
end
