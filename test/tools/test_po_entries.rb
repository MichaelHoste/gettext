# -*- coding: utf-8 -*-
#
# Copyright (C) 2012  Haruka Yoshihara <yoshihara@clear-code.com>
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
#
# License: Ruby's or LGPL
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "gettext/tools/po_entries"

class TestPoEntries < Test::Unit::TestCase
  def setup
    @entries = nil
  end

  class TestSetEntry < self
    def test_normal
      msgid = "msgid"
      msgstr = "msgstr"

      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr

      entry = PoEntry.new(:normal)
      entry.msgid = msgid
      entry.msgstr = msgstr
      assert_equal(entry, @entries[msgid])
    end

    def test_update_existing_entry
      test_normal

      msgid = "msgid"
      new_msgstr = "new_msgstr"
      @entries[msgid] = new_msgstr

      entry = PoEntry.new(:normal)
      entry.msgid = msgid
      entry.msgstr = new_msgstr
      assert_equal(entry, @entries[msgid])
    end
  end

  class TestComment < self
    def test_add
      msgid = "msgid"
      comment = "comment"

      @entries = GetText::PoEntries.new
      @entries.set_comment(msgid, comment)

      entry = PoEntry.new(:normal)
      entry.msgid = msgid
      entry.comment = comment
      assert_equal(entry, @entries[msgid])
      assert_equal(nil, @entries[msgid].msgstr)
    end

    def test_add_to_existing_entry
      msgid = "msgid"
      msgstr = "msgstr"
      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr

      comment = "comment"
      @entries.set_comment(msgid, comment)

      entry = PoEntry.new(:normal)
      entry.msgid = msgid
      entry.msgstr = msgstr
      entry.comment = comment
      assert_equal(entry, @entries[msgid])
    end
  end

  class TestSetType < self
    def test_add
      type = :normal
      msgid = "msgid"
      msgstr = "msgstr"

      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr
      @entries.set_type(msgid, type)

      assert_equal(type, @entries[msgid].type)
    end

    def test_add_to_non_existent_entry
      type = :normal
      msgid = "msgid"

      @entries = GetText::PoEntries.new
      assert_raise(GetText::PoEntries::NonExistentEntryError) do
        @entries.set_type(msgid, type)
      end
    end
  end

  class TestSetMsgctxt < self
    def test_add
      msgctxt = "msgctxt"
      msgid = "msgid"
      msgstr = "msgstr"

      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr
      @entries.set_msgctxt(msgid, msgctxt)

      assert_equal(msgctxt, @entries[msgid].msgctxt)
    end

    def test_add_to_non_existent_entry
      msgctxt = "msgctxt"
      msgid = "msgid"

      @entries = GetText::PoEntries.new
      assert_raise(GetText::PoEntries::NonExistentEntryError) do
        @entries.set_msgctxt(msgid, msgctxt)
      end
    end
  end

  class TestSetMsgidPlurals < self
    def test_add
      msgid = "msgid"
      msgid_plural = "msgid_plural"
      msgstr = "msgstr"

      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr
      @entries.set_msgid_plural(msgid, msgid_plural)

      assert_equal(msgid_plural, @entries[msgid].msgid_plural)
    end

    def test_add_to_non_existent_entry
      msgid = "msgid"
      msgid_plural = "msgid_plural"

      @entries = GetText::PoEntries.new
      assert_raise(GetText::PoEntries::NonExistentEntryError) do
        @entries.set_msgid_plural(msgid, msgid_plural)
      end
    end
  end

  class TestSetSources < self
    def test_add
      msgid = "msgid"
      msgstr = "msgstr"
      sources = ["file.rb:10"]

      @entries = GetText::PoEntries.new
      @entries[msgid] = msgstr
      @entries.set_sources(msgid, sources)

      assert_equal(sources, @entries[msgid].sources)
    end

    def test_add_to_non_existent_entry
      msgid = "msgid"
      sources = ["file.rb:10"]

      @entries = GetText::PoEntries.new
      assert_raise(GetText::PoEntries::NonExistentEntryError) do
        @entries.set_sources(msgid, sources)
      end
    end
  end

  class TestToS < self
  def test_same_filename
    @entries = GetText::PoEntries.new
    hello = "hello"
    hello_translation = "こんにちは"
    hello_sources = ["file.rb:10"]
    hello_comment = "#: file.rb:10"
    bye = "bye"
    bye_translation = "さようなら"
    bye_sources = ["file.rb:20"]
    bye_comment = "#: file.rb:20"

    @entries[""] = header
    @entries.set_comment("", header_comment)

    @entries[hello] = hello_translation
    @entries[hello].sources = hello_sources

    @entries[bye] = bye_translation
    @entries[bye].sources = bye_sources

    expected_po =<<EOP
#{expected_header_comment}
#
msgid ""
msgstr ""
#{expected_header}

#{hello_comment}
msgid "#{hello}"
msgstr "#{hello_translation}"

#{bye_comment}
msgid "#{bye}"
msgstr "#{bye_translation}"
EOP
    assert_equal(expected_po, @entries.to_s)
  end

  def test_different_filename
    @entries = GetText::PoEntries.new
    hello = "hello"
    hello_translation = "こんにちは"
    hello_sources = ["file.rb:10"]
    hello_comment = "#: file.rb:10"
    bye = "bye"
    bye_translation = "さようなら"
    bye_sources = ["test.rb:10"]
    bye_comment = "#: test.rb:10"

    @entries[""] = header
    @entries.set_comment("", header_comment)

    @entries[hello] = hello_translation
    @entries[hello].sources = hello_sources

    @entries[bye] = bye_translation
    @entries[bye].sources = bye_sources

    expected_po =<<EOP
#{expected_header_comment}
#
msgid ""
msgstr ""
#{expected_header}

#{hello_comment}
msgid "#{hello}"
msgstr "#{hello_translation}"

#{bye_comment}
msgid "#{bye}"
msgstr "#{bye_translation}"
EOP
    assert_equal(expected_po, @entries.to_s)
  end

  def test_including_colon_filename
    @entries = GetText::PoEntries.new
    hello = "hello"
    hello_translation = "こんにちは"
    hello_sources = ["file.rb:10"]
    hello_comment = "#: file.rb:10"
    bye = "bye"
    bye_translation = "さようなら"
    bye_sources = ["file:2.rb:10"]
    bye_comment = "#: file:2.rb:10"

    @entries[""] = header
    @entries.set_comment("", header_comment)

    @entries[hello] = hello_translation
    @entries[hello].sources = hello_sources

    @entries[bye] = bye_translation
    @entries[bye].sources = bye_sources

    expected_po =<<EOP
#{expected_header_comment}
#
msgid ""
msgstr ""
#{expected_header}

#{hello_comment}
msgid "#{hello}"
msgstr "#{hello_translation}"

#{bye_comment}
msgid "#{bye}"
msgstr "#{bye_translation}"
EOP
    assert_equal(expected_po, @entries.to_s)
  end

  def test_no_fileno
    @entries = GetText::PoEntries.new
    hello = "hello"
    hello_translation = "こんにちは"
    hello_sources = ["file.rb"]
    hello_comment = "#: file.rb"
    bye = "bye"
    bye_translation = "さようなら"
    bye_sources = ["test.rb"]
    bye_comment = "#: test.rb"

    @entries[""] = header
    @entries.set_comment("", header_comment)

    @entries[hello] = hello_translation
    @entries[hello].sources = hello_sources

    @entries[bye] = bye_translation
    @entries[bye].sources = bye_sources

    expected_po =<<EOP
#{expected_header_comment}
#
msgid ""
msgstr ""
#{expected_header}

#{hello_comment}
msgid "#{hello}"
msgstr "#{hello_translation}"

#{bye_comment}
msgid "#{bye}"
msgstr "#{bye_translation}"
EOP
    assert_equal(expected_po, @entries.to_s)
  end

  private
  def header
    <<EOH
Project-Id-Version: test 1.0.0
POT-Creation-Date: 2012-10-31 12:40+0900
PO-Revision-Date: 2012-11-01 17:46+0900
Last-Translator: FULLNAME <MAIL@ADDRESS>
Language-Team: Japanese
Language: 
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n != 1)
EOH
  end

  def header_comment
    <<EOC
Japanese translations for test package.
Copyright (C) 2012 THE PACKAGE'S COPYRIGHT HOLDER
This file is distributed under the same license as the PACKAGE package.
FULLNAME <MAIL@ADDRESS>, 2012.

EOC
  end

  def expected_header
    expected_header = header.split("\n").collect do |line|
      "\"#{line}\\n\""
    end
    expected_header.join("\n")
  end

  def expected_header_comment
    expected_header_comment = header_comment.split("\n").collect do |line|
      "# #{line}"
    end
    expected_header_comment.join("\n")
  end
end
end
