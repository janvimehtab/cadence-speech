# Cadence

### Speak with rhythm. Improve with insight.

Cadence is a speech practice and analysis app built to help people become more confident, clear, and intentional speakers.

The idea is simple.

You choose a topic, speak about it for two minutes, and Cadence analyzes how you speak. Instead of only telling you whether your speech was "good" or "bad", it looks at different parts of your delivery such as speaking pace, filler words, pauses, and overall clarity.

The goal is not to make people speak perfectly.

The goal is to help people notice their speaking habits and gradually improve them.

---

## What is Cadence?

Many people know what they want to say, but struggle with how they say it.

They may speak too quickly, use filler words without realizing it, pause at awkward moments, or lose their rhythm while explaining an idea.

Cadence was built as a small personal speaking coach that focuses on these patterns.

Each practice session gives you a random topic and a fixed two minute challenge. While you speak, the app analyzes your speech in real time and provides feedback after the session.

Everything is designed to make practice simple, short, and repeatable.

---

## What I Built

### Two Minute Speaking Challenges

Every practice session gives you a topic and a two minute time limit.

The topics are intentionally general and easy to understand, covering areas such as:

- Everyday life
- Personal growth
- People and relationships
- Education
- Work
- Opinions
- The world
- Fun and imagination

The challenge is not about giving the "correct" answer.

It is about practicing how clearly and confidently you can express your thoughts.

---

### Real Time Speech Analysis

While you are speaking, Cadence continuously analyzes your speech.

The live analysis includes:

- Word count
- Speaking pace
- Filler word count
- Pause count
- Silence percentage
- Clarity score
- Average pause duration
- Pause quality

This gives you a quick picture of how you are speaking while you practice.

---

### Contextual Filler Word Detection

One of the problems with simple filler detection is that not every use of a word is actually a filler.

For example:

> "I like this idea."

The word "like" is being used normally.

But:

> "I was, like, really nervous."

Here, "like" is being used conversationally as a filler.

Cadence uses contextual rules to distinguish between these cases instead of simply counting every occurrence of a word.

The app currently analyzes filler patterns including:

- Um
- Uh
- Like
- Basically
- Literally
- So
- You know

---

### Pause Quality Analysis

Pauses are not automatically considered bad.

A good speaker uses pauses to create rhythm, give ideas space, and make important points easier to understand.

Cadence therefore looks at several aspects of pauses:

- Number of pauses
- Total silent time
- Average pause duration
- Percentage of the session spent in silence
- Pause frequency
- Overall pause quality

This allows the app to distinguish between useful pauses and excessive hesitation.

---

### Speech Pace Analysis

Cadence calculates your approximate words per minute and compares your pace against the selected speaking style.

The available modes are:

- Fast / Pitch
- Moderate / Presentation
- Slow / Lecture

The app then provides feedback based on your actual speaking pace.

---

### Performance Score

Each session receives an overall score based on multiple aspects of speech rather than relying on a single metric.

The analysis considers:

- Filler words
- Speaking pace
- Pause quality
- Speaking consistency
- Overall fluency

This creates a more meaningful picture of the session.

---

### Personalized Feedback

After a session, Cadence provides feedback based on the actual performance of that session.

For example, feedback can point out things such as:

- Speaking too quickly
- Excessive filler words
- Very long pauses
- Good use of pauses
- Strong speaking rhythm
- Areas that could be improved

The intention is to make the feedback useful rather than simply displaying numbers.

---

### Session Summary

After finishing a challenge, Cadence provides a summary of the session.

The summary includes:

- Overall score
- Speaking pace
- Word count
- Filler count
- Pause quality
- Silence percentage
- Average pause duration
- Performance feedback
- Filler breakdown

If a session contains too little speech to produce meaningful analysis, Cadence does not create a misleading score.

Instead, it clearly identifies the session as invalid due to insufficient speech.

---

### Practice History

Completed sessions are stored locally so you can look back at previous practice.

The History section includes information such as:

- Session date
- Duration
- Score
- Speaking pace
- Filler count
- Pause performance
- Progress over time

You can also remove previous sessions from your history.

---

### Persistent Settings

Cadence remembers your speaking preferences locally.

You can configure:

- Preferred speaking pace
- Filler detection
- Enabled filler words

This allows the analysis to adapt to your preferred practice style.

---

## Privacy

Cadence is designed around a local-first approach.

There is no backend server required for the core app.

Session information is stored locally using SwiftData.

Speech recognition is handled using Apple's Speech framework.

The project was intentionally designed without building a custom backend or sending session data to an external database.

---

## Built With

Cadence was built using Apple's native frameworks and Swift.

### Technologies

- Swift
- SwiftUI
- AVFoundation
- Speech
- SwiftData
- Charts
- Swift Playgrounds

### Architecture

The project follows a simple layered structure:

```text
SwiftUI Views
↓
ViewModels
↓
Services
↓
Apple Frameworks
↓
SwiftData
