// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DiaryBook {
    enum Mood { Good, Normal, Bad }

    struct DiaryEntry {
        string title;
        string content;
        Mood mood;
        uint256 timestamp;
    }

    mapping(address => DiaryEntry[]) private diaries;

    event DiaryWritten(address indexed writer, uint256 index, Mood mood);

    function writeDiary(
        string calldata _title,
        string calldata _content,
        Mood _mood
    ) external {
        diaries[msg.sender].push(
            DiaryEntry({
                title: _title,
                content: _content,
                mood: _mood,
                timestamp: block.timestamp
            })
        );
        uint256 newIndex = diaries[msg.sender].length - 1;
        emit DiaryWritten(msg.sender, newIndex, _mood);
    }

    function diaryCount() external view returns (uint256) {
        return diaries[msg.sender].length;
    }

    function getDiary(
        uint256 _index
    )
        external
        view
        returns (
            string memory title,
            string memory content,
            Mood mood,
            uint256 timestamp
        )
    {
        require(_index < diaries[msg.sender].length, "Index out of bounds");
        DiaryEntry storage entry = diaries[msg.sender][_index];
        return (entry.title, entry.content, entry.mood, entry.timestamp);
    }

    function getDiariesByMood(
        Mood _mood
    ) external view returns (DiaryEntry[] memory filtered) {
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        for (uint256 i; i < all.length; i++) {
            if (all[i].mood == _mood) count++;
        }
        filtered = new DiaryEntry[](count);
        uint256 idx;
        for (uint256 i; i < all.length; i++) {
            if (all[i].mood == _mood) {
                filtered[idx] = all[i];
                idx++;
            }
        }
    }

    function getDiariesByDateRange(
        uint256 _start,
        uint256 _end
    ) external view returns (DiaryEntry[] memory filtered) {
        require(_start <= _end, "Invalid range");
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        for (uint256 i; i < all.length; i++) {
            if (all[i].timestamp >= _start && all[i].timestamp <= _end) count++;
        }
        filtered = new DiaryEntry[](count);
        uint256 idx;
        for (uint256 i; i < all.length; i++) {
            if (all[i].timestamp >= _start && all[i].timestamp <= _end) {
                filtered[idx] = all[i];
                idx++;
            }
        }
    }

    function getDiariesByTitleKeyword(
        string calldata _keyword
    ) external view returns (DiaryEntry[] memory filtered) {
        bytes memory needle = bytes(_keyword);
        require(needle.length > 0, "Empty keyword");
        DiaryEntry[] storage all = diaries[msg.sender];
        uint256 count;
        for (uint256 i; i < all.length; i++) {
            if (_contains(all[i].title, needle)) count++;
        }
        filtered = new DiaryEntry[](count);
        uint256 idx;
        for (uint256 i; i < all.length; i++) {
            if (_contains(all[i].title, needle)) {
                filtered[idx] = all[i];
                idx++;
            }
        }
    }

    function _contains(string memory _haystack, bytes memory _needle) internal pure returns (bool) {
        bytes memory haystack = bytes(_haystack);
        if (_needle.length > haystack.length) return false;
        for (uint256 i; i <= haystack.length - _needle.length; i++) {
            bool matchFound = true;
            for (uint256 j; j < _needle.length; j++) {
                if (haystack[i + j] != _needle[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) return true;
        }
        return false;
    }
}