# Toasty Breadis

This repository uses a **contrived** example to showcase a simple refactoring of some test helpers to eventually leverage [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html). The objective is to show how and why one might want to use Concerns instead of regular module inclusion or extension.

## Caveats

This scenario illustrates the usage of Concerns, not how to write good code or tests. For example, this code would probably be better tested by treating `ToasterTest` as a unit test and stubbing out `Breadis` entirely. Moreover, `Breadis` would be vulnerable to race conditions in any kind of concurrent environment. Not to mention the toasters prepare orders in **random order**, instead of using some sort of queueing system!
