// we can either update a field in the record?
// or send out an event, but then we need to reload?
// oooor, update the field _and_ send out the event
window.addEventListener("load", function () {
	
	Vue.component("data-lanes-configurator", {
		mixins: [nabu.page.views.data.DataCommon],
		template: "#data-lanes-configurator",
		activate: function(done) {
			var self = this;
			var event = null;
			this.activate(done);
		},
		created: function() {
			this.create();
		},
		methods: {
			addLane: function() {
				if (!this.cell.state.lanes) {
					Vue.set(this.cell.state, "lanes", []);
				}
				this.cell.state.lanes.push({
					name: null,
					states: []
				});
			}
		}
	});
	
	Vue.view("data-lanes", {
		mixins: [nabu.page.views.data.DataCommon],
		activate: function(done) {
			var self = this;
			var event = null;
			this.activate(function() {
				done();
			});
		},
		created: function() {
			this.create();
		},
		data: function() {
			return {
				dragging: null,
				configuring: false
			}
		},
		methods: {
			configurator: function() {
				return "data-lanes-configurator";
			},
			acceptRecord: function(event, state) {
				var value = state.value == null ? null : this.$services.page.interpret(state.value);
				if (this.dragging && this.cell.state.stateField && value != this.dragging[this.cell.state.stateField]) {
					if (event) {
						event.preventDefault();
					}
					return true;
				}
				return false;
			},
			getRecordClasses: function(record) {
				var classes = this.$services.page.getDynamicClasses(this.cell.state.styles, {record:record}, this);
				if (record == this.dragging) {
					classes.push("dragged");
				}
			},
			dropRecord: function(event, state) {
				var value = state.value == null ? null : this.$services.page.interpret(state.value);
				console.log("dropped", value, this.dragging, this.cell.state.stateField);
				if (this.dragging && this.cell.state.stateField) {
					this.dragging[this.cell.state.stateField] = value;
					this.update(this.dragging);
					this.dragging = null;
				}
			},
			dragRecord: function(event, state, record) {
				this.dragging = record;
			},
			stopDrag: function(event) {
				this.dragging = null;
				this.$services.page.clearDrag(event);
			},
			getRecordsInState: function(state) {
				var value = state.value == null ? null : this.$services.page.interpret(state.value);
				return this.records.filter(function(record) {
					return record.state == value;
				});
			}
		}
	});
});