class Stringtie < Formula
  desc "Transcript assembly and quantification for RNA-Seq"
  homepage "http://ccb.jhu.edu/software/stringtie"
  url "http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.2.4.tar.gz"
  sha256 "7fcd64c3ad73816cdb446c5d703a1c46cf828db88871221267532355168b0dc9"
  head "https://github.com/gpertea/stringtie.git"

  # doi "10.1038/nbt.3122"
  # tag "bioinformatics"

  bottle do
    cellar :any_skip_relocation
    sha256 "240dca6cb315b04fb50aa51ef80e4f8d55118a89ae35954611c2a82bf17cefbb" => :el_capitan
    sha256 "8cf1175bb39b744920c841c979a20e9e89627a45f6ef3b59011b5866ac56b906" => :yosemite
    sha256 "1583cb027d940bd432ca1b87a61d8545fbbdda3760f615af541eb906fca7add7" => :mavericks
  end

  def install
    system "make", "release"
    bin.install "stringtie"
    doc.install "README", "LICENSE"
  end

  test do
    assert_match "transcripts", shell_output("stringtie 2>&1", 1)
  end
end
